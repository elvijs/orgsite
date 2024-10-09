# Expose ORG_DIR and REMOTE envvars for the rest of the scripts. NOT checked in.
include settings.env
export $(shell sed 's/=.*//' settings.env)  # export all the envvars


# use -- -Q to pass in argv into the elisp script
html: clean
	emacs -Q --script build-site.el -- -Q $(ORG_DIR) $(HTML_DIR)

clean:
	rm -Rf $(HTML_DIR)/

local_server:
	python3 -m http.server --directory=$(HTML_DIR)


#
# Remote deployment
#
deploy_html: html
	scp -r $(HTML_DIR)/* $(REMOTE_DESTINATION)

set_up_1a_systemd_service:
	scp orgsite.service $(REMOTE_USER)@$(REMOTE_HOST):/etc/systemd/system/$(SERVICE_NAME).service


set_up_a_systemd_service:
	# Copy the service file to a temporary location with regular permissions
	scp orgsite.service $(REMOTE_USER)@$(REMOTE_HOST):/tmp/$(SERVICE_NAME).service
	# Move the file to the correct directory with sudo, reload, enable, and start the service
	ssh $(REMOTE_USER)@$(REMOTE_HOST) \
		'sudo mv /tmp/$(SERVICE_NAME).service /etc/systemd/system/$(SERVICE_NAME).service && \
		sudo systemctl daemon-reload && \
		sudo systemctl enable $(SERVICE_NAME) && \
		sudo systemctl start $(SERVICE_NAME)'

start_service:
	ssh $(REMOTE_USER)@$(REMOTE_HOST) 'sudo systemctl daemon-reload && sudo systemctl enable $(SERVICE_NAME) && sudo systemctl start $(SERVICE_NAME)'


check_service_status:
	ssh $(REMOTE_USER)@$(REMOTE_HOST) 'sudo systemctl status $(SERVICE_NAME)'

# To debug startup failures `journalctl -u orgsite.service`

# Deploy notes for the cloudflared tunnel in systemctl
# Followed https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/as-a-service/linux/
# But had to manually point to the config folder
# sudo cloudflared --config /home/pi/.cloudflared/config.yml service install