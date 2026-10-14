// For fdopen() in stdio.h:
// https://stackoverflow.com/questions/75776439/any-way-to-get-fdopen-functionality-with-c99
// TODO you can avoid this by changing the fileReader and fileWriter funcs
#ifdef _POSIX_C_SOURCE
#undef _POSIX_C_SOURCE
#endif
#define _POSIX_C_SOURCE 200809L

#include <signal.h>    // kill()
#include <stdint.h>    // uint8_t
#include <stdio.h>     // fprintf(), perror(), stderr
#include <stdlib.h>    // abort()
#include <sys/types.h> // pid_t
#include <unistd.h>    // dup2(), execlp(), fork(), pipe()

#include "cmp.h"

typedef int64_t NvimInteger;
typedef double NvimFloat;
typedef struct {
  char *data;
  size_t size;
} NvimString;

static bool readBytes(void *data, size_t sz, FILE *fh) {
  return fread(data, sizeof(uint8_t), sz, fh) == (sz * sizeof(uint8_t));
}

static bool fileReader(cmp_ctx_t *ctx, void *data, size_t limit) {
  int fd = *(int *)ctx->buf;
  read();
  return readBytes(data, limit, (FILE *)ctx->buf);
}

static bool fileSkipper(cmp_ctx_t *, size_t) { abort(); }

static size_t fileWriter(cmp_ctx_t *ctx, const void *data, size_t count) {
  int fd = *(int *)ctx->buf;
  ssize_t bytesWritten = write(fd, data, count * sizeof(uint8_t));
  return (size_t)bytesWritten == count;
}

static inline void check(cmp_ctx_t *cmp, bool success) {
  if (!success) {
    fprintf(stderr, "%s", cmp_strerror(cmp));
    abort();
  }
}

static void request(cmp_ctx_t *cmp, size_t methodSize,
                    const char method[methodSize]) {
  static uint32_t msgid = 0;
  constexpr NvimInteger REQUEST_TYPE = 0;

  // [type, msgid, method, params]
  check(cmp, cmp_write_array(cmp, 4));
  check(cmp, cmp_write_integer(cmp, REQUEST_TYPE));
  check(cmp, cmp_write_integer(cmp, msgid++));
  check(cmp, cmp_write_str(cmp, method, methodSize));
  check(cmp, cmp_write_array(cmp, 0));
  fflush(cmp->buf);
}

// static void parseResponse(cmp_ctx_t *cmp, uint8_t *buf) {
//   uint32_t arraySize;
//   check(cmp, cmp_read_array(cmp, &arraySize));
//   cmp_read_int();
// }

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

int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv) {
  int nvimToClientRead;
  int nvimToClientWrite;
  int clientToNvimRead;
  int clientToNvimWrite;
  int res = 0;
  {
    int twoPipes[2];
    res = pipe(twoPipes);
    if (res < 0) {
      perror("pipe() failed");
      abort();
    }
    nvimToClientRead = twoPipes[0];
    nvimToClientWrite = twoPipes[1];
  }
  {
    int twoPipes[2];
    res = pipe(twoPipes);
    if (res < 0) {
      perror("pipe() failed");
      abort();
    }
    clientToNvimRead = twoPipes[0];
    clientToNvimWrite = twoPipes[1];
  }
  pid_t nvimPid = fork();

  if (nvimPid == 0) {
    res = dup2(nvimToClientWrite, STDOUT_FILENO);
    if (res < 0) {
      perror("dup2() failed");
      abort();
    }
    res = close(nvimToClientRead);
    if (res < 0) {
      perror("close() failed");
      abort();
    }
    res = dup2(clientToNvimRead, STDIN_FILENO);
    if (res < 0) {
      perror("dup2() failed");
      abort();
    }
    res = close(clientToNvimWrite);
    if (res < 0) {
      perror("close() failed");
      abort();
    }
    // execlp("nvim", "nvim", "-u", "NONE", "--embed", nullptr);
    execlp("nvim", "nvim", "--embed", nullptr);
    // execlp("/home/chris/git/flutter_nvim/c/stub.rb", "stub.rb", nullptr);
    perror("execlp() failed");
    abort();
  }

  res = close(nvimToClientWrite);
  if (res < 0) {
    perror("close() failed");
    abort();
  }
  res = close(clientToNvimRead);
  if (res < 0) {
    perror("close() failed");
    abort();
  }

  // TODO check pid for error
  // FILE *writeFile = fdopen(clientToNvimWrite, "w");
  // if (writeFile == nullptr) {
  //  perror("fdopen() failed");
  //  abort();
  //}

  // FILE *readFile = fdopen(nvimToClientRead, "r");
  // if (readFile == nullptr) {
  //   perror("fdopen() failed");
  //   abort();
  // }

  cmp_ctx_t cmpWrite, cmpRead = {0};
  cmp_init(&cmpWrite, &clientToNvimWrite, nullptr, fileSkipper, fileWriter);
  cmp_init(&cmpRead, &nvimToClientRead, fileReader, fileSkipper, nullptr);

  const char method[] = "nvim_get_api_info";
  request(&cmpWrite, sizeof(method), method);

  printf("[cnvim.exe] Awaiting array read...\n");
  uint32_t arrayLen;
  check(&cmpRead, cmp_read_array(&cmpRead, &arrayLen));
  // size_t n = read(nvimToClientRead, buf, BUFSIZ);
  printf("Got an array of len %d from Neovim.\n", arrayLen);
  // parseResponse(&cmpRead, buf);

  kill(nvimPid, SIGKILL);
  printf("\nDone.\n");
}
