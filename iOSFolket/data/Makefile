RM					=	/bin/rm

.PHONY: all fetch clean convert_all

all: fetch convert_all
	@echo "\nDone\n"

fetch:
	@echo "Fetching needed files"
	sh get_files.sh

clean:
	@echo "Clean up"
	$(RM) -rf folkets_en_sv_public.xml
	$(RM) -rf folkets_sv_en_public.xml

convert_all:
	@echo "Converting Folkets dictionary file into Apples DictionarySchema"
	@# WTF? In Makefiles you escape with $?
	sed '$$ d' folkets_sv_en_public.xml > start.xml
	tail -n +3 folkets_en_sv_public.xml > end.xml
	cat start.xml end.xml > all.xml
	$(RM) start.xml end.xml
