use strict;
use warnings;
use ExtUtils::MakeMaker;
require 5;
use Config;
use MakefileSubs;

my $lib_version;

WriteMakefile(AgentInitMakeParams());

Check_Version($lib_version);

sub AgentInitMakeParams {
    my $opts;
    my %Params = (
		  'NAME'		=> 'NetSNMP::agent',
		  'VERSION_FROM'	=> 'agent.pm', # finds $VERSION
		  'XSPROTOARG'          => '-prototypes',
		  'PM'                => { 
		      'agent.pm' => '$(INST_LIBDIR)/agent.pm',
		      'netsnmp_request_infoPtr.pm' =>
			  '$(INST_LIBDIR)/agent/netsnmp_request_infoPtr.pm'
		  },
		  'PREREQ_PM'           => {},
		  );

    AddCommonParams(\%Params);
                                   
    my ($snmp_lib, $snmp_llib, $sep);

    $opts = NetSNMPGetOpts();

    if ($Config{'osname'} eq 'MSWin32' && !defined($ENV{'OSTYPE'})) {
      $sep = '\\';
      my $snmp_lib_file = 'netsnmp.lib';
      my $snmp_link_lib = 'netsnmp';
      my $lib_dir;
      my $agent_link_lib = 'netsnmpagent';
      my $mibs_link_lib = 'netsnmpmibs';

      if (lc($opts->{'debug'}) eq "true") {
        $lib_dir = 'lib\\debug';
      }
      else {
        $lib_dir = 'lib\\release';
      }
    
      if (lc($opts->{'insource'}) eq "true") {
	$Params{'LIBS'} = "-L" . $MakefileSubs::basedir . "\\win32\\$lib_dir\\ -l$snmp_link_lib -l$agent_link_lib " .
                "-l$mibs_link_lib";
      }
      else {
	my @LibDirs = split (';',$ENV{LIB});
        my $LibDir;
	if ($opts->{'prefix'}) {
	  push (@LibDirs,"$ENV{'NET-SNMP-PATH'}${sep}lib");
	}
	my $noLibDir = 1;
	while ($noLibDir) {
	  $LibDir = find_files(["$snmp_lib_file"],\@LibDirs);
	  if ($LibDir ne '') {
	    $noLibDir = 0;
            # Put quotes around LibDir to allow spaces in paths
            $LibDir = '"' . $LibDir . '"';          
	  }
	  else
	  {
	    @LibDirs = ();
	    $LibDirs[0] = prompt("The Net-SNMP library ($snmp_lib_file) could not be found.\nPlease enter the directory where it is located:");
	    $LibDirs[0] =~ s/\\$//;
	  }
	}
	$Params{LIBS} = "-L$LibDir -l$snmp_link_lib -l$agent_link_lib -l$mibs_link_lib";
      }
    }
    else {
	$Params{'LIBS'}   = `$opts->{'nsconfig'} --base-agent-libs` or
	    die "net-snmp-config failed\n";
	chomp($Params{'LIBS'});
        $lib_version = `$opts->{'nsconfig'} --version` or
	    die "net-snmp-config failed\n";
	if (lc($opts->{'insource'}) eq "true") {
	    $Params{'LIBS'} =
                "-L" . abs_path("../../snmplib/.libs") .
                " -L" . abs_path("../../snmplib") .
                " -L" . abs_path("../../agent/.libs") .
                " -L" . abs_path("../../agent") .
                " " . $Params{'LIBS'};
#	} else {
	    $Params{'LIBS'} = `$opts->{'nsconfig'} --libdir` . $Params{'LIBS'};
#	    $Params{'PREREQ_PM'} = {'NetSNMP::OID' => '0.1'};
	}
    }

    return(%Params);
}
