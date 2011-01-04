BUILD_SUBDIRS = app_uart_test app_uart_back2back
TEST_SUBDIRS = app_uart_test

%.all:
	cd $* && xmake all

%.clean:
	cd $* && xmake clean

%.test:
	cd $* && xmake test

all: $(foreach x, $(BUILD_SUBDIRS), $x.all)
clean: $(foreach x, $(BUILD_SUBDIRS), $x.clean)
test: $(foreach x, $(TEST_SUBDIRS), $x.test)
