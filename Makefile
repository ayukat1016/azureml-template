TEMPLATE_DIR=consumer provider
WORK_DIR=./work

define inplace_replace
	find $(1) -type f -print0 | xargs -0 sed -i.bak -e $(2)
	find $(1) -type f -name '*.bak' -delete
endef

.PHONY: template2work
template2work:
	rm -rf $(WORK_DIR)
	mkdir -p $(WORK_DIR)
	cp -rf $(TEMPLATE_DIR) $(WORK_DIR)
	# aml registry rg
	$(call inplace_replace,$(WORK_DIR),"s/dev-ml-template-rg101/dev-ml-template-rg119/g")
	# aml registry name
	$(call inplace_replace,$(WORK_DIR),"s/dev-ml-template-registry101/dev-ml-template-registry119/g")
	# storage account name
	$(call inplace_replace,$(WORK_DIR),"s/devmlst101/devmlst119/g")
	# storage container name
	$(call inplace_replace,$(WORK_DIR),"s/devmlstc101/devmlstc119/g")
	# consumer rg
	$(call inplace_replace,$(WORK_DIR),"s/dev-ml-template-rg201/dev-ml-template-rg219/g")
	# workspace
	$(call inplace_replace,$(WORK_DIR),"s/dev-ml-template-ws201/dev-ml-template-ws219/g")


WORK_TEMPLATE_DIR=work/consumer work/provider
CURRENT_DIR=.

.PHONY: work2template
work2template:
	rm -rf $(TEMPLATE_DIR)
	cp -rf $(WORK_TEMPLATE_DIR) $(CURRENT_DIR)
	# aml registry rg
	$(call inplace_replace,$(TEMPLATE_DIR),"s/dev-ml-template-rg1xx/dev-ml-template-rg101/g")
	# aml registry name
	$(call inplace_replace,$(TEMPLATE_DIR),"s/dev-ml-template-registry1xx/dev-ml-template-registry101/g")
	# storage account name
	$(call inplace_replace,$(TEMPLATE_DIR),"s/devmlst1xx/devmlst101/g")
	# storage container name
	$(call inplace_replace,$(TEMPLATE_DIR),"s/devmlstc1xx/devmlstc101/g")
	# consumer rg
	$(call inplace_replace,$(TEMPLATE_DIR),"s/dev-ml-template-rg2xx/dev-ml-template-rg201/g")
	# workspace
	$(call inplace_replace,$(TEMPLATE_DIR),"s/dev-ml-template-ws2xx/dev-ml-template-ws201/g")
