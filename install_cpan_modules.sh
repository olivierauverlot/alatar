# This script installs CPAN dependencies
# --------------------------------------------------
/usr/bin/env perl -MCPAN -e 'install App::cpanminus'
cpanm Data::Dumper
cpanm String::Util
cpanm Getopt::Long
cpanm Regexp::Common
cpanm File::Path
cpanm XML::Writer
cpanm IO::File
cpanm File::Basename