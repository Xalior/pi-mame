# circle-app.mk — pi-mame kernel link rule.
#
# Include AFTER Circle's Rules.mk. Replaces the image link rule so kernels
# link with build/ld/circle-tls.ld (TLS sections adjacent) while the Circle
# tree itself stays pristine. GNU make warns about the overridden recipe;
# that warning is expected and harmless.

APP_LDSCRIPT ?= $(dir $(lastword $(MAKEFILE_LIST)))circle-tls.ld

$(TARGET).img: $(OBJS) $(LIBS) $(APP_LDSCRIPT)
	@echo "  LD    $(TARGET).elf (circle-tls.ld)"
	@$(LD) -o $(TARGET).elf -Map $(TARGET).map $(LDFLAGS) \
		-T $(APP_LDSCRIPT) $(CRTBEGIN) $(OBJS) \
		--start-group $(LIBS) $(EXTRALIBS) --end-group $(CRTEND)
	@echo "  DUMP  $(TARGET).lst"
	@$(OBJDUMP) -d $(TARGET).elf | $(CPPFILT) > $(TARGET).lst
	@echo "  COPY  $(TARGET).img"
	@$(OBJCOPY) $(TARGET).elf -O binary $(TARGET).img
	@echo -n "  WC    $(TARGET).img => "
	@wc -c < $(TARGET).img
