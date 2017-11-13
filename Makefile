.PHONY: update-hosts

update-hosts:
	./just-hosts OnlyHTTPS/blockerList.json OnlyHTTPS/blockerList-mixedcontent.json
