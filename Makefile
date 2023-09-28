TEMPLATE_DIR=./lightgbm-template
WORK_DIR=./work/lightgbm-template

.PHONY: template2work
template2work:
	rm -rf $(WORK_DIR)
	cp -rf $(TEMPLATE_DIR) $(WORK_DIR)
	# aml registry rg
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg103/dev-ml-template-rg105/g"
	# aml registry name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-registry103/dev-ml-template-registry105/g"
	# storage account name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlst103/devmlst105/g"
	# storage container name
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlstc103/devmlstc105/g"
	# consumer rg
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg203/dev-ml-template-rg205/g"
	# workspace
	find $(WORK_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-ws203/dev-ml-template-ws205/g"

.PHONY: work2template
work2template:
	rm -rf $(TEMPLATE_DIR)
	cp -rf $(WORK_DIR) $(TEMPLATE_DIR)
	# aml registry rg
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg10x/dev-ml-template-rg101/g"
	# aml registry name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-registry10x/dev-ml-template-registry101/g"
	# storage account name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlst10x/devmlst101/g"
	# storage container name
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/devmlstc10x/devmlstc101/g"
	# consumer rg
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-rg20x/dev-ml-template-rg201/g"
	# workspace
	find $(TEMPLATE_DIR) -type f -print0 | xargs -0 sed -i -e "s/dev-ml-template-ws20x/dev-ml-template-ws201/g"