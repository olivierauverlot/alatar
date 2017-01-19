tests:
	perl -MTest::Harness -e '$$Test::Harness::verbose=1; runtests @ARGV;' ./t/*.t
bin:
	pp -o /tmp/alatar extract.pl