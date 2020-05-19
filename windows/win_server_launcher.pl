#!/usr/bin/perl

use Time::HiRes qw(usleep);

print "Akka's Windows Server Launcher\n";

my ${base_binary_path} = "./";
if (-e "bin/zone.exe") {
    ${base_binary_path} = "bin/";
}

my $kill_all_on_start        = 0;
my $no_query_serv            = 0;
my $use_loginserver          = 0;
my $zone_start_in_background = 0;
my $start_in_background      = 0;
my $zones_to_launch          = "";

#::: Arguments
# zone_background_start = Starts zone processes in the background
# background_start = Starts all processes in the background
# zones="40" = specified x number of zones to launch
# loginserver = Launch loginserver
# kill_all_on_start = Kills any running processes on start
# no_query_serv - disable running of queryserv

my $n = 0;
while ($ARGV[$n]) {
    print $n . ': ' . $ARGV[$n] . "\n" if $Debug;
    if ($ARGV[$n] eq "kill_all_on_start") {
        $kill_all_on_start = 1;
    }
    if ($ARGV[$n] eq "no_query_serv") {
        $no_query_serv = 1;
    }
    if ($ARGV[$n] eq "loginserver") {
        $use_loginserver = 1;
        print "Loginserver set to run...\n";
    }
    if ($ARGV[$n] eq "zone_background_start") {
        $zone_start_in_background = 1;
        print "Zone background starting enabled...\n";
    }
    if ($ARGV[$n] eq "background_start") {
        $start_in_background = 1;
        print "All process background starting enabled...\n";
    }
    if ($ARGV[$n] =~ /zones=/i) {
        my @data = split('=', $ARGV[$n]);
        print "Zones to launch: " . $data[1] . "\n";
        $zones_to_launch = $data[1];
    }
    $n++;
}

if ($kill_all_on_start) {

    my @processes = (
        "zone.exe",
        "ucs.exe",
        "queryserv.exe",
        "world.exe",
        "shared_memory.exe",
        "loginserver.exe",
        "eqlaunch.exe",
    );

    foreach my $process (@processes) {
        system("start taskkill /IM \"${base_binary_path}$process\" /F > nul");
    }
}

if (!$zones_to_launch) {
    $zones_to_launch = 10;
}
if (!$start_in_background) {
    $start_in_background = 0;
}

if ($start_in_background == 1) {
    $background_start = " /b ";
    $pipe_redirection = " > nul ";
}
else {
    $background_start = "";
    $pipe_redirection = "";
}

my %process_status = (
    0 => "DOWN",
    1 => "UP",
);

my $zone_process_count        = 0;
my $world_process_count       = 0;
my $queryserv_process_count   = 0;
my $ucs_process_count         = 0;
my $loginserver_process_count = 0;

sub print_status
{
    print "									\r";
    print "World: " . $process_status{$world_process_count} . " ";
    print "Zones: (" . $zone_process_count . "/" . $zones_to_launch . ") ";
    print "UCS: " . $process_status{$ucs_process_count} . " ";
    print "Queryserv: " . $process_status{$queryserv_process_count} . " ";
    if ($use_loginserver) {
        print "Loginserver: " . $process_status{$loginserver_process_count} . " ";
    }
    print "\r";
}

while (1) {
    $zone_process_count        = 0;
    $world_process_count       = 0;
    $queryserv_process_count   = 0;
    $ucs_process_count         = 0;
    $loginserver_process_count = 0;

    my $l_processes = `TASKLIST`;
    my @processes   = split("\n", $l_processes);
    foreach my $val (@processes) {
        if ($val =~ /ucs/i) {
            $ucs_process_count++;
        }
        if ($val =~ /world/i) {
            $world_process_count++;
        }
        if ($val =~ /zone/i) {
            $zone_process_count++;
        }
        if ($val =~ /queryserv/i) {
            $queryserv_process_count++;
        }
        if ($val =~ /loginserver/i) {
            $loginserver_process_count++;
        }
    }

    print_status();

    #############################################
    # loginserver
    #############################################

    if ($use_loginserver) {
        for ($i = $loginserver_process_count; $i < 1; $i++) {
            system("start " . $background_start . " ${base_binary_path}loginserver.exe " . $pipe_redirection);
            $loginserver_process_count++;
            print_status();
        }
    }

    #############################################
    # world
    #############################################

    for ($i = $world_process_count; $i < 1; $i++) {
        system("start " . $background_start . " ${base_binary_path}world.exe " . $pipe_redirection);
        $world_process_count++;
        print_status();
        sleep(1);
    }

    #############################################
    # zone
    #############################################

    for ($i = $zone_process_count; $i < $zones_to_launch; $i++) {
        if ($zone_start_in_background == 1) {
            system("start /b ${base_binary_path}zone.exe > nul");
        }
        else {
            system("start " . $background_start . " ${base_binary_path}zone.exe " . $pipe_redirection);
        }
        $zone_process_count++;
        print_status();
        usleep(100);
    }

    #############################################
    # queryserv
    #############################################

    if ($no_query_serv != 1) {
        for ($i = $queryserv_process_count; $i < 1; $i++) {
            system("start " . $background_start . " ${base_binary_path}queryserv.exe " . $pipe_redirection);
            print_status();
        }
    }

    #############################################
    # ucs
    #############################################

    for ($i = $ucs_process_count; $i < 1; $i++) {
        system("start " . $background_start . " ${base_binary_path}ucs.exe " . $pipe_redirection);
        print_status();
    }

    sleep(1);
}
