#define _POSIX_C_SOURCE 199309L
#include <dlfcn.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>

typedef ssize_t (*orig_read_t)(int fd, void *buf, size_t count);
typedef ssize_t (*orig_write_t)(int fd, const void *buf, size_t count);
typedef int (*orig_open_t)(const char *pathname, int flags, ...);
typedef int (*orig_close_t)(int fd);

static orig_read_t original_read = NULL;
static orig_write_t original_write = NULL;
static orig_open_t original_open = NULL;
static orig_close_t original_close = NULL;

static unsigned int read_sleep_ms = 0;
static unsigned int write_sleep_ms = 0;
static unsigned int open_sleep_ms = 0;
static unsigned int close_sleep_ms = 0;

static void sleep_ms(unsigned int ms) {
	if (ms > 0) {
		struct timespec ts;
		ts.tv_sec = ms / 1000;
		ts.tv_nsec = (ms % 1000) * 1000000;
		nanosleep(&ts, NULL);
	}
}

__attribute__((constructor))
static void init() {
	original_read = (orig_read_t)dlsym(RTLD_NEXT, "read");
	if (!original_read) {
		fprintf(stderr, "Error loading original read function: %s\n", dlerror());
	}

	original_write = (orig_write_t)dlsym(RTLD_NEXT, "write");
	if (!original_write) {
		fprintf(stderr, "Error loading original write function: %s\n", dlerror());
	}

	original_open = (orig_open_t)dlsym(RTLD_NEXT, "open");
	if (!original_open) {
		fprintf(stderr, "Error loading original open function: %s\n", dlerror());
	}

	original_close = (orig_close_t)dlsym(RTLD_NEXT, "close");
	if (!original_close) {
		fprintf(stderr, "Error loading original close function: %s\n", dlerror());
	}

	char *env_val;

	if ((env_val = getenv("CRAWLIO_READ_SLEEP_MS"))) {
		read_sleep_ms = atoi(env_val);
	}

	if ((env_val = getenv("CRAWLIO_WRITE_SLEEP_MS"))) {
		write_sleep_ms = atoi(env_val);
	}

	if ((env_val = getenv("CRAWLIO_OPEN_SLEEP_MS"))) {
		open_sleep_ms = atoi(env_val);
	}

	if ((env_val = getenv("CRAWLIO_CLOSE_SLEEP_MS"))) {
		close_sleep_ms = atoi(env_val);
	}

	if ((env_val = getenv("CRAWLIO_SLEEP_MS"))) {
		int general_sleep_ms = atoi(env_val);
		// Only override if specific values weren't set
		if (!getenv("CRAWLIO_READ_SLEEP_MS")) read_sleep_ms = general_sleep_ms;
		if (!getenv("CRAWLIO_WRITE_SLEEP_MS")) write_sleep_ms = general_sleep_ms;
		if (!getenv("CRAWLIO_OPEN_SLEEP_MS")) open_sleep_ms = general_sleep_ms;
		if (!getenv("CRAWLIO_CLOSE_SLEEP_MS")) close_sleep_ms = general_sleep_ms;
	}

	if (getenv("CRAWLIO_DEBUG")) {
		fprintf(stderr, "crawlio initialized with delays:\n");
		fprintf(stderr, "  read: %u ms\n", read_sleep_ms);
		fprintf(stderr, "  write: %u ms\n", write_sleep_ms);
		fprintf(stderr, "  open: %u ms\n", open_sleep_ms);
		fprintf(stderr, "  close: %u ms\n", close_sleep_ms);
	}
}

ssize_t read(int fd, void *buf, size_t count) {
	sleep_ms(read_sleep_ms);
	return original_read(fd, buf, count);
}

ssize_t write(int fd, const void *buf, size_t count) {
	sleep_ms(write_sleep_ms);
	return original_write(fd, buf, count);
}

int open(const char *pathname, int flags, ...) {
	sleep_ms(open_sleep_ms);

	mode_t mode = 0;
	if (flags & O_CREAT) {
		va_list args;
		va_start(args, flags);
		mode = va_arg(args, mode_t);
		va_end(args);
	}

	if (flags & O_CREAT) {
		return original_open(pathname, flags, mode);
	} else {
		return original_open(pathname, flags);
	}
}

int close(int fd) {
	sleep_ms(close_sleep_ms);
	return original_close(fd);
}
