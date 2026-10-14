#include <assert.h>    // assert()
#include <signal.h>    // kill()
#include <stdint.h>    // uint8_t
#include <stdio.h>     // fprintf(), perror(), stderr
#include <stdlib.h>    // abort()
#include <string.h>    // strdup()
#include <sys/types.h> // pid_t
#include <unistd.h>    // dup2(), execlp(), fork(), pipe()

#include "cmp.h"

typedef int64_t NvimInteger;
typedef double NvimFloat;
typedef struct {
  char *data;
  size_t size;
} NvimString;

typedef enum : int {
  messageTypeRequest = 0,
  messageTypeResponse = 1,
  messageTypeNotification = 2,
} MessageType;

typedef enum {
  nvimGetApiInfo,
} RequestMethod;

/// NOTE: Allocates a new string for `namePtr`.
static bool requestMethodName(RequestMethod method, char **namePtr,
                              size_t *size) {
  switch (method) {
  case nvimGetApiInfo: {
    const char name[] = "nvim_get_api_info";
    *size = sizeof(name);
    *namePtr = strdup(name);
    if (*namePtr == nullptr) {
      perror("strdup() failed");
      abort();
    }
    return true;
  }
  default:
    abort();
  }
}

static bool fileReader(cmp_ctx_t *ctx, void *data, size_t limit) {
  int fd = *(int *)ctx->buf;
  ssize_t n = read(fd, data, limit);
  if (n < 0) {
    perror("read() failed");
    abort();
  }
  return (size_t)n == limit;
}

static bool fileSkipper(cmp_ctx_t *, size_t) { abort(); }

static size_t fileWriter(cmp_ctx_t *ctx, const void *data, size_t count) {
  int fd = *(int *)ctx->buf;
  ssize_t bytesWritten = write(fd, data, count * sizeof(uint8_t));
  return (size_t)bytesWritten == count;
}

static inline void check(cmp_ctx_t *cmp, bool success) {
  if (!success) {
    fprintf(stderr, "%s\n", cmp_strerror(cmp));
    abort();
  }
}

static inline void _indent(unsigned int depth) {
  for (unsigned int i = 0; i < depth; i++) {
    fputc(' ', stdout);
    fputc(' ', stdout);
  }
}

static void request(cmp_ctx_t *cmp, RequestMethod method) {
  static uint32_t msgid = 0;

  char *methodName;
  size_t methodSize;
  if (!requestMethodName(method, &methodName, &methodSize)) {
    abort();
  }

  // [type, msgid, method, params]
  check(cmp, cmp_write_array(cmp, 4));
  check(cmp, cmp_write_integer(cmp, messageTypeRequest));
  check(cmp, cmp_write_integer(cmp, msgid++));
  check(cmp, cmp_write_str(cmp, methodName, methodSize));
  check(cmp, cmp_write_array(cmp, 0));

  free(methodName);
}

static void _debugMsgpackObjectRec(cmp_ctx_t *cmp, cmp_object_t *obj,
                                   unsigned int depth) {
  uint32_t size = 0;
  switch (obj->type) {
  case CMP_TYPE_NIL:
    _indent(depth);
    fputs("nil", stdout);
    return;
  case CMP_TYPE_FIXARRAY:
    size = obj->as.array_size;
    _indent(depth);
    printf("[\n");
    for (unsigned int i = 0; i < size; i++) {
      if (i > 0) {
        printf(",\n");
      }
      cmp_object_t curObj = {0};
      check(cmp, cmp_read_object(cmp, &curObj));
      _debugMsgpackObjectRec(cmp, &curObj, depth + 1);
    }
    printf("\n");
    _indent(depth);
    printf("]\n");
    return;
  case CMP_TYPE_NEGATIVE_FIXNUM:
  case CMP_TYPE_POSITIVE_FIXNUM: {
    int32_t i = 0;
    check(cmp, cmp_object_as_int(obj, &i));
    _indent(depth);
    printf("%d", i);
    return;
  }

  case CMP_TYPE_FIXSTR:
  case CMP_TYPE_STR8:
  case CMP_TYPE_STR16:
  case CMP_TYPE_STR32: {
    size = 0;
    check(cmp, cmp_object_as_str(obj, &size));
    {
      // TODO: use a static buffer
      char *string = calloc(size + 3, sizeof(uint8_t));
      string[0] = '"';
      string[size + 1] = '"';
      string[size + 2] = '\0';

      cmp->read(cmp, string + 1, size);
      _indent(depth);
      printf("%s", string);

      free(string);
    }
    return;
  }

  case CMP_TYPE_FIXMAP:
  case CMP_TYPE_BOOLEAN:
  case CMP_TYPE_BIN8:
  case CMP_TYPE_BIN16:
  case CMP_TYPE_BIN32:
  case CMP_TYPE_EXT8:
  case CMP_TYPE_EXT16:
  case CMP_TYPE_EXT32:
  case CMP_TYPE_FLOAT:
  case CMP_TYPE_DOUBLE:
  case CMP_TYPE_UINT8:
  case CMP_TYPE_UINT16:
  case CMP_TYPE_UINT32:
  case CMP_TYPE_UINT64:
  case CMP_TYPE_SINT8:
  case CMP_TYPE_SINT16:
  case CMP_TYPE_SINT32:
  case CMP_TYPE_SINT64:
  case CMP_TYPE_FIXEXT1:
  case CMP_TYPE_FIXEXT2:
  case CMP_TYPE_FIXEXT4:
  case CMP_TYPE_FIXEXT8:
  case CMP_TYPE_FIXEXT16:
  case CMP_TYPE_ARRAY16:
  case CMP_TYPE_ARRAY32:
  case CMP_TYPE_MAP16:
  case CMP_TYPE_MAP32:
    abort();
    break;
  }
}

static void debugMsgpackObject(cmp_ctx_t *cmp, cmp_object_t *obj) {
  _debugMsgpackObjectRec(cmp, obj, 0);
  fflush(stdout);
}

static void parseNvimMessage(cmp_ctx_t *cmp) {
  uint32_t arraySize;
  check(cmp, cmp_read_array(cmp, &arraySize));

  MessageType messageType;
  check(cmp, cmp_read_int(cmp, &messageType));

  switch (messageType) {
  case messageTypeRequest:
    abort();
    break;
  case messageTypeResponse:
    // [type, msgid, error, result]
    assert(arraySize == 4);
    uint32_t msgId = 0;
    check(cmp, cmp_read_uint(cmp, &msgId));
    cmp_object_t obj = {0};
    check(cmp, cmp_read_object(cmp, &obj));
    if (!cmp_object_is_nil(&obj)) {
      debugMsgpackObject(cmp, &obj);
      abort();
    }
    break;
  case messageTypeNotification:
    // [type, method, params]
    // TODO implement
    abort();
    break;
  }
}

[[maybe_unused]]
static inline void _writeDebugFile(size_t n, uint8_t *buf) {
  FILE *f = fopen("msg.dat", "w");
  if (f == nullptr) {
    perror("fopen() failed");
    abort();
  }
  fwrite(buf, sizeof(uint8_t), n, f);
  printf("Wrote data to msg.dat.\n");
}

typedef struct {
  int read;
  int write;
} Pipe;

Pipe pipeNew() {
  int twoPipes[2];
  int res = pipe(twoPipes);
  if (res < 0) {
    perror("pipe() failed");
    abort();
  }
  return (Pipe){
      .read = twoPipes[0],
      .write = twoPipes[1],
  };
}

Pipe pipeAndFork(pid_t *pid) {
  Pipe nvimToClient = pipeNew();
  Pipe clientToNvim = pipeNew();

  *pid = fork();
  int res = 0;

  if (*pid == 0) {
    res = dup2(nvimToClient.write, STDOUT_FILENO);
    if (res < 0) {
      perror("dup2() failed");
      abort();
    }
    res = close(nvimToClient.read);
    if (res < 0) {
      perror("close() failed");
      abort();
    }
    res = dup2(clientToNvim.read, STDIN_FILENO);
    if (res < 0) {
      perror("dup2() failed");
      abort();
    }
    res = close(clientToNvim.write);
    if (res < 0) {
      perror("close() failed");
      abort();
    }
    execlp("nvim", "nvim", "-u", "NONE", "--embed", nullptr);
    perror("execlp() failed");
    abort();
  }

  res = close(nvimToClient.write);
  if (res < 0) {
    perror("close() failed");
    abort();
  }
  res = close(clientToNvim.read);
  if (res < 0) {
    perror("close() failed");
    abort();
  }

  return (Pipe){
      .read = nvimToClient.read,
      .write = clientToNvim.write,
  };
}

int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv) {
  pid_t pid = 0;
  Pipe p = pipeAndFork(&pid);
  cmp_ctx_t cmpWrite, cmpRead = {0};
  cmp_init(&cmpWrite, &p.write, nullptr, fileSkipper, fileWriter);
  cmp_init(&cmpRead, &p.read, fileReader, fileSkipper, nullptr);

  request(&cmpWrite, nvimGetApiInfo);

  printf("Awaiting array read...\n");
  parseNvimMessage(&cmpRead);

  kill(pid, SIGKILL);
  printf("\nDone.\n");
}
