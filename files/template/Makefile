TARGET		= template
INSTALL_DIR = $(PREFIX)/usr/local/bin

.SUFFIXES:

.PHONY: all clean install uninstall

all: $(TARGET)

clean:
	rm -f $(TARGET)

install: $(INSTALL_DIR)/$(TARGET)

uninstall:
	rm -f $(INSTALL_DIR)/$(TARGET)

$(TARGET):
	touch $@

$(INSTALL_DIR):
	mkdir -p $@

$(INSTALL_DIR)/$(TARGET): $(TARGET) $(INSTALL_DIR)
	install $< $@

