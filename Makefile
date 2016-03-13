HOMEWORKS=homework1 homework2

err = (printf "\n\033[0;31mERROR: %s\033[0m\n\n" $(1) && exit 1)
check-var = (test `wc -w <<< $(1)` != "0" || $(call err,"\`$(2)\` is required."))

check-path:
	#
	# >> Make sure path argument has been set
	#
	$(call check-var,"${path}","path")

check-scheme:
	#
	# >> Make sure path argument has been set
	#
	$(call check-var,"${scheme}","scheme")


# Dependency -----------------------------------------------------------------------------------------------------------

install:
	#
	# >> Install dependent packages if necessary
	#
	gem list -i bundler 1>/dev/null 2>&1 || gem install bundle
	bundle check 1>/dev/null 2>&1 || bundle install


# Git ------------------------------------------------------------------------------------------------------------------

check-git-clean: check-path
	#
	# >> Make Sure git repo is clean
	#
	test `cd ${path} && git status --porcelain | wc -l` == "0" || $(call err,"git is not clean")

clean-git: check-path
	#
	# >> Clean git repository
	#
	cd ${path} && git checkout -- .


# Inject ---------------------------------------------------------------------------------------------------------------

inject-command:=bundle exec ruby lib/inject-uitest.rb ${path} ${scheme}

inject-homework1: check-path check-scheme check-git-clean install
	#
	# >> Inject UITests for homework1
	#
	$(inject-command) hw1-calculator-test/


# Run ------------------------------------------------------------------------------------------------------------------

run-test: check-scheme check-path install
	#
	# >> Run Tests
	#
	cd ${path} && scan -s ${scheme} --clean -o /dev/null

$(HOMEWORKS): % : inject-% run-test clean-git
