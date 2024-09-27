TEMPLATE_DIR=consumer provider
WORK_DIR=./work

.PHONY: template2work
template2work:
	rm -rf $(WORK_DIR)
	mkdir -p $(WORK_DIR)
	cp -rf $(TEMPLATE_DIR) $(WORK_DIR)
	# aml registry rg
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg101/dev-ml-template-rg117/g"
	# aml registry name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-registry101/dev-ml-template-registry117/g"
	# storage account name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlst101/devmlst117/g"
	# storage container name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlstc101/devmlstc117/g"
	# consumer rg
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg201/dev-ml-template-rg217/g"
	# workspace
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-ws201/dev-ml-template-ws217/g"


WORK_TEMPLATE_DIR=work/consumer work/provider
CURRENT_DIR=.

.PHONY: work2template
work2template:
	rm -rf $(TEMPLATE_DIR)
	cp -rf $(WORK_TEMPLATE_DIR) $(CURRENT_DIR)
	# aml registry rg
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg1xx/dev-ml-template-rg101/g"
	# aml registry name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-registry1xx/dev-ml-template-registry101/g"
	# storage account name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlst1xx/devmlst101/g"
	# storage container name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlstc1xx/devmlstc101/g"
	# consumer rg
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg2xx/dev-ml-template-rg201/g"
	# workspace
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-ws2xx/dev-ml-template-ws201/g"