# Expose ORG_DIR and REMOTE envvars for the rest of the scripts. NOT checked in.
include settings.env
export $(shell sed 's/=.*//' settings.env)  # export all the envvars

STATIC_SITE=html

# use -- -Q to pass in argv into the script; test using the following
# (print argv)
# (print (nth 2 argv))
html: clean
	emacs -Q --script build-site.el -- -Q $(ORG_DIR)


server:
	python3 -m http.server --directory=$(STATIC_SITE)


clean:
	rm -Rf $(STATIC_SITE)/
