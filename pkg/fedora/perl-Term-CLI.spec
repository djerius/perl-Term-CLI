Name:           perl-Term-CLI
Version:        0.03
Release:        1%{?dist}
Summary:        CLI interpreter based on Term::ReadLine
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Term-CLI/
Source0:        http://www.cpan.org/modules/by-module/Term/Term-CLI-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl >= 0:5.014001
BuildRequires:  perl(Data::Dumper) >= 2.160
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(File::Temp) >= 0.2304
BuildRequires:  perl(FindBin) >= 1.51
BuildRequires:  perl(Getopt::Long) >= 2.48
BuildRequires:  perl(List::Util) >= 1.42
BuildRequires:  perl(Modern::Perl) >= 1.20170117
BuildRequires:  perl(Moo) >= 2.002005
BuildRequires:  perl(Moo::Role) >= 2.002005
BuildRequires:  perl(namespace::clean) >= 0.27
BuildRequires:  perl(parent) >= 0.234
BuildRequires:  perl(Pod::Text::Termcap) >= 2.06
BuildRequires:  perl(POSIX) >= 1.65
BuildRequires:  perl(Term::ReadLine) >= 1.15
BuildRequires:  perl(Term::ReadLine::Gnu) >= 1.35
BuildRequires:  perl(Test::Class) >= 0.50
BuildRequires:  perl(Test::Compile) >= v1.3.0
BuildRequires:  perl(Test::Exception) >= 0.43
BuildRequires:  perl(Test::More) >= 1.302103
BuildRequires:  perl(Text::ParseWords) >= 3.30
BuildRequires:  perl(Types::Standard) >= 1.000005
Requires:       perl(Data::Dumper) >= 2.160
Requires:       perl(FindBin) >= 1.51
Requires:       perl(Getopt::Long) >= 2.48
Requires:       perl(List::Util) >= 1.42
Requires:       perl(Modern::Perl) >= 1.20170117
Requires:       perl(Moo) >= 2.002005
Requires:       perl(Moo::Role) >= 2.002005
Requires:       perl(namespace::clean) >= 0.27
Requires:       perl(parent) >= 0.234
Requires:       perl(Pod::Text::Termcap) >= 2.06
Requires:       perl(POSIX) >= 1.65
Requires:       perl(Term::ReadLine) >= 1.15
Requires:       perl(Term::ReadLine::Gnu) >= 1.35
Requires:       perl(Text::ParseWords) >= 3.30
Requires:       perl(Types::Standard) >= 1.000005
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Implement an easy-to-use command line interpreter based on
Term::ReadLine(3p) and Term::ReadLine::Gnu(3p).

%prep
%setup -q -n Term-CLI-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

perldoc -t perlgpl > COPYING
perldoc -t perlartistic > Artistic

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes META.json README COPYING Artistic
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Mon Feb 26 2018 Steven Bakker <sb@monkey-mind.net> 0.03-1
* Sun Feb 25 2018 Steven Bakker <sb@monkey-mind.net> 0.02-1
- Specfile autogenerated by cpanspec 1.78.