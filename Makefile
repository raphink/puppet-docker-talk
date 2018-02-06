ifndef PROJECT
$(warning PROJECT is not defined. Defaulting to "default")
PROJECT=default
endif

ifeq (,$(wildcard $(CURDIR)/$(PROJECT).json))
$(warning $(PROJECT).json does not exist)
else

# Get variables from JSON file
json_value=$(shell jgrep -s $1 < $(PROJECT).json)
metadata=$(shell jgrep -s courseware-metadata.$1 < $(PROJECT).json || echo $2)

TITLE=$(call metadata,title)
ifeq ($(strip $(TITLE)),)
$(error courseware-metadata.title is undefined in $(PROJECT).json)
endif
SUBTITLE=$(call metadata,subtitle)
ifeq ($(strip $(SUBTITLE)),)
$(error courseware-metadata.subtitle is undefined in $(PROJECT).json)
endif
DEPARTMENT=$(call metadata,department)
ifeq ($(strip $(DEPARTMENT)),)
$(error courseware-metadata.department is undefined in $(PROJECT).json)
endif
VERSION=$(call metadata,version)
ifeq ($(strip $(VERSION)),)
$(error courseware-metadata.version is undefined in $(PROJECT).json)
endif

COURSE_BOOK_TITLE=$(call metadata,course_book_title,Student Guide)
EXERCISE_BOOK_TITLE=$(call metadata,exercise_book_title,Exercise \& Lab Guide)
MERGED_BOOK_TITLE=$(call metadata,merged_book_title,Course Guide)

USER=$(call json_value,user)
ifeq ($(strip $(USER)),)
$(warning user is undefined in $(PROJECT).json)
endif
PASSWORD=$(call json_value,password)
ifeq ($(strip $(PASSWORD)),)
$(warning password is undefined in $(PROJECT).json)
endif
endif

PDF_DIR=pdf
PRINT_URL=http://showoff:9090
PRINT_DIR=print
PRINT_BASE_CMD=PROJECT=$(PROJECT) docker-compose exec weasyprint weasyprint
PRINT_PDF_CMD=$(PRINT_BASE_CMD)
PRINT_SLIDES_CMD=$(PRINT_BASE_CMD) -s /data/$(COMMON_DIR)/slides.css -m screen
COURSE=$(PDF_DIR)/$(PROJECT)_$(VERSION).pdf
COURSE_NOCOVER=$(PDF_DIR)/$(PROJECT)_$(VERSION)_nocover.pdf
EXERCISES=$(PDF_DIR)/$(PROJECT)_$(VERSION)_exercises.pdf
EXERCISES_NOCOVER=$(PDF_DIR)/$(PROJECT)_$(VERSION)_exercises_nocover.pdf
MERGED=$(PDF_DIR)/$(PROJECT)_$(VERSION)_merged.pdf
MERGED_NOCOVER=$(PDF_DIR)/$(PROJECT)_$(VERSION)_merged_nocover.pdf
COMMON_DIR=common
YEAR=$(shell date +'%Y')
DATE=$(shell date +'%d.%m.%Y')
DATE_TODAY=$(shell date +%s)
# Edge effect (2 days off)?
DATE_1900=$(shell date -d'12/30/1899' +%s)
DAYS_SINCE_1900=$(shell echo "$$(( ($(DATE_TODAY) - $(DATE_1900)) / 86400 ))")

# Covers
INTROS=$(COVER_DIR)/$(PROJECT)_$(VERSION)_course_cover.pdf $(COVER_DIR)/$(PROJECT)_$(VERSION)_exercises_cover.pdf
COVERS=$(COVER_DIR)/$(PROJECT)_$(VERSION)_course_cover_a3.pdf $(COVER_DIR)/$(PROJECT)_$(VERSION)_exercises_cover_a3.pdf
COVER_TEMPLATE=$(shell echo $(COMMON_DIR)/*.ott)
COVER_DIR=cover
UNOCONV_CMD= docker run -v $(CURDIR):/data camptocamp/unoconv -f pdf \
	 	-F Client_Name="$(TITLE)" \
	 	-F Document_Title="$(SUBTITLE)" \
	 	-F Document_Last_Version="$(VERSION)" \
		-F Document_Date="$(DAYS_SINCE_1900)" \
	 	--stdout

# Slides
PDF_COURSE_SLIDES=$(PDF_DIR)/$(PROJECT)_$(VERSION)_slides.pdf
PDF_EXERCISES_SLIDES=$(PDF_DIR)/$(PROJECT)_$(VERSION)_exercises_slides.pdf
PDF_SOLUTIONS_SLIDES=$(PDF_DIR)/$(PROJECT)_$(VERSION)_solutions_slides.pdf

# Make targets

all: dirs books covers slides

books: $(INTROS) $(COURSE) $(COURSE_NOCOVER) $(EXERCISES) $(EXERCISES_NOCOVER) $(MERGED) $(MERGED_NOCOVER)

covers: $(COVERS)

slides: $(PDF_COURSE_SLIDES) $(PDF_EXERCISES_SLIDES) $(PDF_SOLUTIONS_SLIDES)

$(PDF_COURSE_SLIDES): dirs
	$(PRINT_SLIDES_CMD) $(PRINT_URL)/print/handouts "/data/$@"

$(PDF_EXERCISES_SLIDES): dirs
	$(PRINT_SLIDES_CMD) $(PRINT_URL)/supplemental/exercises "/data/$@"

$(PDF_SOLUTIONS_SLIDES): dirs
	$(PRINT_SLIDES_CMD) $(PRINT_URL)/supplemental/solutions "/data/$@"

dirs:
	mkdir -p $(COVER_DIR) $(PRINT_DIR) $(PDF_DIR)
	ln -sf ../_images-base/c2c_logo_departements/rapport_logo_haut_droite_$(DEPARTMENT)_rgb.png _images/department_logo.png
	echo "body {\n  -weasy-string-set: copyright \"© Camptocamp $(YEAR) / V$(VERSION) / $(DATE)\";\n}" > copyright.css


# Books

$(PRINT_DIR)/$(PROJECT).pdf: dirs
	$(PRINT_PDF_CMD) $(PRINT_URL)/print/handouts "/data/$@"

$(COURSE): dirs $(COVER_DIR)/$(PROJECT)_$(VERSION)_course_cover.pdf  $(PRINT_DIR)/$(PROJECT).pdf
	pdftk "$(PRINT_DIR)/$(PROJECT).pdf" dump_data \
		    | awk '{if ($$1=="BookmarkPageNumber:") { print $$1" "$$2+1} else { print }}' > "$(PRINT_DIR)/$(PROJECT).info"
	pdftk A="$(COVER_DIR)/$(PROJECT)_$(VERSION)_course_cover.pdf" \
	      B="$(PRINT_DIR)/$(PROJECT).pdf" \
	      cat A1 B A2 output "$(PRINT_DIR)/$(PROJECT).with_cover.pdf"
	pdftk "$(PRINT_DIR)/$(PROJECT).with_cover.pdf" update_info "$(PRINT_DIR)/$(PROJECT).info" output "$@"

$(COURSE_NOCOVER): dirs $(COVER_DIR)/$(PROJECT)_$(VERSION)_course_cover.pdf $(PRINT_DIR)/$(PROJECT).pdf
	cp $(PRINT_DIR)/$(PROJECT).pdf "$@"

$(PRINT_DIR)/$(PROJECT)_exercises_instructions.pdf: dirs
	$(PRINT_PDF_CMD) $(PRINT_URL)/supplemental/exercises "/data/$@"

$(PRINT_DIR)/$(PROJECT)_exercises_solutions.pdf: dirs
	$(PRINT_PDF_CMD) $(PRINT_URL)/supplemental/solutions "/data/$@"

$(EXERCISES_NOCOVER): dirs $(PRINT_DIR)/$(PROJECT)_exercises_instructions.pdf $(PRINT_DIR)/$(PROJECT)_exercises_solutions.pdf
	pdftk A="$(PRINT_DIR)/$(PROJECT)_exercises_instructions.pdf" \
		    B="$(PRINT_DIR)/$(PROJECT)_exercises_solutions.pdf" \
				cat A B output "$@"

$(EXERCISES): dirs $(COVER_DIR)/$(PROJECT)_$(VERSION)_exercises_cover.pdf $(EXERCISES_NOCOVER)
	pdftk A="$(COVER_DIR)/$(PROJECT)_$(VERSION)_exercises_cover.pdf" \
		    B="$(EXERCISES_NOCOVER)" \
				cat A1 B Aend output "$@"

$(MERGED_NOCOVER): dirs $(COURSE_NOCOVER) $(EXERCISES_NOCOVER)
	pdftk A="$(COURSE_NOCOVER)" \
		    B="$(EXERCISES_NOCOVER)" \
				cat A B output "$@"

$(MERGED): dirs $(COVER_DIR)/$(PROJECT)_$(VERSION)_merged_cover.pdf $(MERGED_NOCOVER)
	pdftk A="$(COVER_DIR)/$(PROJECT)_$(VERSION)_merged_cover.pdf" \
		    B="$(MERGED_NOCOVER)" \
				cat A1 B Aend output "$@"

# Covers

$(COVER_TEMPLATE): dirs

%_course_cover.pdf: $(COVER_TEMPLATE)
	# Requires https://github.com/dagwieers/unoconv/pull/193 to be merged
	# Force python3 until https://github.com/dagwieers/unoconv/pull/175 is merged
	$(UNOCONV_CMD) -F Document_Type="$(COURSE_BOOK_TITLE)" "/data/$<" | \
	 	pdftk - cat 1 end output "$@"

%_exercises_cover.pdf: $(COVER_TEMPLATE)
	# Requires https://github.com/dagwieers/unoconv/pull/193 to be merged
	# Force python3 until https://github.com/dagwieers/unoconv/pull/175 is merged
	$(UNOCONV_CMD) -F Document_Type="$(EXERCISE_BOOK_TITLE)" "/data/$<" | \
	 	pdftk - cat 1 end output "$@"

%_merged_cover.pdf: $(COVER_TEMPLATE)
	# Requires https://github.com/dagwieers/unoconv/pull/193 to be merged
	# Force python3 until https://github.com/dagwieers/unoconv/pull/175 is merged
	$(UNOCONV_CMD) -F Document_Type="$(MERGED_BOOK_TITLE)" "/data/$<" | \
	 	pdftk - cat 1 end output "$@"

%_a3.pdf: %_a3.ps
	epstopdf $<
	pdf270 --outfile "$*_a3-turned.pdf" $@
	mv $*_a3-turned.pdf $@

%_a3.ps: %.pdf
	pdftk $< cat end 1 output - \
	 	| pdf2ps -dLanguageLevel=3 - -  \
		| psnup -2 -s1 -h42.60cm -w30.40cm > $@

init:
	mkdir -p _files _preshow _demos _images
	cp $(COMMON_DIR)/course_template.json .
	cp -r $(COMMON_DIR)/Course_Overview .
	cp -r $(COMMON_DIR)/Course_Conclusion .
	ln -sf $(COMMON_DIR)/showoff.css
	ln -sf $(COMMON_DIR)/_images-base
	ln -sf $(COMMON_DIR)/_fonts
	ln -sf $(COMMON_DIR)/docker/run.sh
	ln -sf $(COMMON_DIR)/docker-compose.yml

run:
	PROJECT=$(PROJECT) docker-compose up -d

clean:
	rm -rf $(COVER_DIR) $(PRINT_DIR) $(PDF_DIR)
	rm -rf copyright.css
	rm -f $(PROJECT).pdf $(PROJECT)_exercises_instructions.pdf $(PROJECT)_exercises_solutions.pdf
