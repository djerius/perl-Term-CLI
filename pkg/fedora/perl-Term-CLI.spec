Name:           perl-Term-CLI
Version:        0.052002
Release:        1%{?dist}
Summary:        CLI interpreter based on Term::ReadLine
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Term-CLI/
Source0:        http://www.cpan.org/modules/by-module/Term/Term-CLI-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl-interpreter >= 0:5.14
BuildRequires:  perl-generators
BuildRequires:  perl(Exporter) >= 5.71
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(File::Temp) >= 0.2304
BuildRequires:  perl(File::Which) >= 1.09
BuildRequires:  perl(FindBin) >= 1.50
BuildRequires:  perl(Getopt::Long) >= 2.42
BuildRequires:  perl(List::Util) >= 1.38
BuildRequires:  perl(Locale::Maketext) >= 1.25
BuildRequires:  perl(Locale::Maketext::Lexicon::Gettext) >= 1.00
BuildRequires:  perl(Moo) >= 1.000001
BuildRequires:  perl(Moo::Role)
BuildRequires:  perl(namespace::clean) >= 0.25
BuildRequires:  perl(parent) >= 0.228
BuildRequires:  perl(Pod::Coverage::TrustPod)
BuildRequires:  perl(Pod::Text::Termcap) >= 2.08
BuildRequires:  perl(Scalar::Util) >= 1.38
BuildRequires:  perl(strict) >= 1.00
BuildRequires:  perl(subs) >= 1.00
BuildRequires:  perl(Term::ReadLine) >= 1.14
BuildRequires:  perl(Term::ReadLine::Gnu) >= 1.24
BuildRequires:  perl(Test::Class)
BuildRequires:  perl(Test::Compile) >= 1.2.0
BuildRequires:  perl(Test::Exception) >= 0.35
BuildRequires:  perl(Test::More) >= 1.001002
BuildRequires:  perl(Test::Output) >= 1.03
BuildRequires:  perl(Test::Pod)
BuildRequires:  perl(Test::Pod::Coverage)
BuildRequires:  perl(Text::ParseWords) >= 3.29
BuildRequires:  perl(Types::Standard) >= 1.000005
BuildRequires:  perl(warnings) >= 1.00
BuildRequires:  make >= 4.0
Requires:       perl(Exporter) >= 5.71
Requires:       perl(File::Which) >= 1.09
Requires:       perl(FindBin) >= 1.50
Requires:       perl(Getopt::Long) >= 2.42
Requires:       perl(List::Util) >= 1.38
Requires:       perl(Locale::Maketext) >= 1.25
Requires:       perl(Locale::Maketext::Lexicon::Gettext) >= 1.00
Requires:       perl(Moo) >= 1.000001
Requires:       perl(Moo::Role)
Requires:       perl(namespace::clean) >= 0.25
Requires:       perl(parent) >= 0.228
Requires:       perl(Pod::Text::Termcap) >= 2.08
Requires:       perl(Scalar::Util) >= 1.38
Requires:       perl(subs) >= 1.00
Requires:       perl(Term::ReadLine) >= 1.14
Requires:       perl(Term::ReadLine::Gnu) >= 1.24
Requires:       perl(Text::ParseWords) >= 3.29
Requires:       perl(Types::Standard) >= 1.000005
Requires:       perl(warnings) >= 1.00
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Provides:       perl(Term::CLI) = %{version}
Provides:       perl(Term::CLI::Argument) = %{version}
Provides:       perl(Term::CLI::PerlFeatures) = %{version}
Provides:       perl(Term::CLI::Argument::Bool) = %{version}
Provides:       perl(Term::CLI::Argument::Enum) = %{version}
Provides:       perl(Term::CLI::Argument::Filename) = %{version}
Provides:       perl(Term::CLI::Argument::Number) = %{version}
Provides:       perl(Term::CLI::Argument::Number::Float) = %{version}
Provides:       perl(Term::CLI::Argument::Number::Int) = %{version}
Provides:       perl(Term::CLI::Argument::String) = %{version}
Provides:       perl(Term::CLI::Base) = %{version}
Provides:       perl(Term::CLI::Command) = %{version}
Provides:       perl(Term::CLI::Command::Help) = %{version}
Provides:       perl(Term::CLI::Element) = %{version}
Provides:       perl(Term::CLI::L10N) = %{version}
Provides:       perl(Term::CLI::L10N::en) = %{version}
Provides:       perl(Term::CLI::L10N::nl) = %{version}
Provides:       perl(Term::CLI::ReadLine) = %{version}
Provides:       perl(Term::CLI::Role::ArgumentSet) = %{version}
Provides:       perl(Term::CLI::Role::CommandSet) = %{version}
Provides:       perl(Term::CLI::Role::HelpText) = %{version}

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

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes cpanfile examples LICENSE META.json README tutorial
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Thu May 19 2021 Steven Bakker <sbakker@cpan.org> 0.052002-1
- New upstream release.
* Fri Apr 30 2021 Steven Bakker <sbakker@cpan.org> 0.052001-1
- New upstream release.
* Mon Nov 18 2019 Steven Bakker <sbakker@cpan.org> 0.051007-1
- New upstream release.
* Wed Nov 6 2019 Steven Bakker <sbakker@cpan.org> 0.051005-1
- New upstream release.
* Tue Nov 5 2019 Steven Bakker <sbakker@cpan.org> 0.051004-2
- Fix BuildRequires and Provides
* Tue Nov 5 2019 Steven Bakker <sbakker@cpan.org> 0.051004-1
- New upstream release.
* Wed Jul 11 2018 Steven Bakker <sbakker@cpan.org> 0.051003-1
- New upstream release.
* Fri Mar 16 2018 Steven Bakker <sbakker@cpan.org> 0.051002-1
- New upstream release.
* Fri Mar 16 2018 Steven Bakker <sbakker@cpan.org> 0.05002-1
- New upstream release.
* Tue Mar 13 2018 Steven Bakker <sbakker@cpan.org> 0.04008-1
- New upstream release.
* Tue Mar 13 2018 Steven Bakker <sbakker@cpan.org> 0.04007-1
- New upstream release.
* Sat Mar 10 2018 Steven Bakker <sbakker@cpan.org> 0.04004-1
- New upstream release.
* Mon Feb 26 2018 Steven Bakker <sbakker@cpan.org> 0.03002-1
- New upstream release.
* Mon Feb 26 2018 Steven Bakker <sbakker@cpan.org> 0.03001-1
- New upstream release.
* Mon Feb 26 2018 Steven Bakker <sbakker@cpan.org> 0.03-1
- New upstream release.
* Sun Feb 25 2018 Steven Bakker <sbakker@cpan.org> 0.02-1
- Specfile autogenerated by cpanspec 1.78.
