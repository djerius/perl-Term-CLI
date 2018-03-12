requires "Exporter" => "5.71";
requires "File::Which" => "1.09";
requires "FindBin" => "1.51";
requires "Getopt::Long" => "2.42";
requires "List::Util" => "1.38";
requires "Locale::Maketext" => "1.25";
requires "Locale::Maketext::Lexicon::Gettext" => "1.00";
requires "Modern::Perl" => "1.20140107";
requires "Moo" => "1.006001";
requires "Moo::Role" => "1.006001";
requires "POSIX" => "1.38_03";
requires "Pod::Text::Termcap" => "2.08";
requires "Scalar::Util" => "1.38";
requires "Term::ReadLine" => "1.14";
requires "Term::ReadLine::Gnu" => "1.24";
requires "Text::ParseWords" => "3.29";
requires "Types::Standard" => "1.000005";
requires "namespace::clean" => "0.25";
requires "parent" => "0.228";
requires "perl" => "5.014_001";
requires "subs" => "1.02";
requires "warnings" => "1.23";

on 'test' => sub {
  requires "File::Temp" => "0.2304";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Class" => "0";
  requires "Test::Compile" => "v1.2.0";
  requires "Test::Exception" => "0.35";
  requires "Test::More" => "1.001002";
  requires "Test::Output" => "1.03";
  requires "Test::Pod" => "0";
  requires "Test::Pod::Coverage" => "0";
  requires "strict" => "1.08";
  requires "warnings" => "1.23";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
