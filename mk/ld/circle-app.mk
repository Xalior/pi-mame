# circle-app.mk — pi-mame kernel link rule.
#
# Include AFTER Circle's Rules.mk. Replaces the image link rule so kernels
# link with mk/ld/circle-tls.ld (TLS sections adjacent) while the Circle
# tree itself stays pristine. GNU make warns about the overridden recipe;
# that warning is expected and harmless.
#
# Kernels carrying the patchable-defaults block (docs/pi-mame-poc2.html;
# shared ABI in boot-picker/defaultsblock.h) set APP_LDSCRIPT to
# mk/ld/circle-defaults.ld and APP_DEFAULTS_BLOCK=1: every produced image
# is then gated on the block's magic sitting at image offset 0x800 — the
# seatbelt every pre-boot patcher verifies before writing. A failed gate
# deletes the image.

APP_LDSCRIPT ?= $(dir $(lastword $(MAKEFILE_LIST)))circle-tls.ld
APP_DEFAULTS_BLOCK ?=

# APP_WHOLE_ARCHIVES: archives (a subset of LIBS — keep them there, LIBS is
# the prerequisite list) whose EVERY member must load. This is the seatbelt
# against silent symbol shadowing: an object linked directly always beats an
# archive member the linker never pulls, so a leftover stub can quietly
# replace a library's working implementation and no error says so. Forcing
# the library's members in turns that class into a loud duplicate-symbol
# failure at link time.
APP_WHOLE_ARCHIVES ?=

$(TARGET).img: $(OBJS) $(LIBS) $(APP_LDSCRIPT)
	@echo "  LD    $(TARGET).elf ($(notdir $(APP_LDSCRIPT)))"
	@$(LD) -o $(TARGET).elf -Map $(TARGET).map $(LDFLAGS) \
		-T $(APP_LDSCRIPT) $(CRTBEGIN) $(OBJS) \
		--start-group \
		$(if $(APP_WHOLE_ARCHIVES),--whole-archive $(APP_WHOLE_ARCHIVES) --no-whole-archive) \
		$(filter-out $(APP_WHOLE_ARCHIVES),$(LIBS)) \
		$(EXTRALIBS) --end-group $(CRTEND)
	@echo "  DUMP  $(TARGET).lst"
	@$(OBJDUMP) -d $(TARGET).elf | $(CPPFILT) > $(TARGET).lst
	@echo "  COPY  $(TARGET).img"
	@$(OBJCOPY) $(TARGET).elf -O binary $(TARGET).img
ifeq ($(strip $(APP_DEFAULTS_BLOCK)),1)
	@if [ "`dd if=$(TARGET).img bs=4 skip=512 count=1 2>/dev/null`" = "PM8D" ]; \
	then \
		echo "  GATE  $(TARGET).img defaults magic at 0x800: OK"; \
	else \
		echo "  GATE  $(TARGET).img: defaults magic ABSENT at 0x800 — image deleted"; \
		rm -f $(TARGET).img; \
		exit 1; \
	fi
endif
	@echo -n "  WC    $(TARGET).img => "
	@wc -c < $(TARGET).img
