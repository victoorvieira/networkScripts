#!/usr/bin/perl

if (not defined $ARGV[0]){

print "USAGE: ./interfaceDump.pl INTERFACE_NAME\n";
print "ex: ./interfaceDump.pl eth0\n";

}

else{

my $intf1=$ARGV[0];
my $colTime=300;
chomp(my $hostname=`hostname -s`);

open($interfaceDumpCsv, ">>", "$hostname"."_"."$intf1"."_"."interfaceDump.csv") or die "Problem when creating the CSV file";
print $interfaceDumpCsv "timestamp;totalPkt;pktSec;totalPktOutLocal;pktSecOutLocal;totalRetrans;retransSec\n";
close $interfaceDumpCsv;

my $checkNum=0;
my $finalNum=1000; # Set the loop to run 1000 times

while ($checkNum < $finalNum) {

my $tcpCmd="tcpdump -G $colTime -W 1 -w interfaceDump.pcap -i $intf1";
my $qtdPkt=`tcpdump -r interfaceDump.pcap.count |wc -l`;
my $qtdPkt=$qtdPkt/1; # Remove the newline from the wc -l
my $qtdPktSec=$qtdPkt/$colTime;
my $totalRetransInicio=`netstat -s |grep "segments retransmited" |cut -d ' ' -f 5`;

open($interfaceDumpLog, ">>", "$hostname"."_"."$intf1"."_"."interfaceDump.log") or die "Problem when creating the output log";
open($interfaceDumpCsv, ">>", "$hostname"."_"."$intf1"."_"."interfaceDump.csv") or die "Problem when creating the CSV file";

my ($seg,$min,$hora,$dia,$mes,$ano)=localtime(time);
$ano=$ano+1900;
$mes=$mes+1;
if ($mes < 10) { $mes = "0".$mes; }
if ($dia < 10) { $dia = "0".$dia; }
if ($hora < 10) { $hora = "0".$hora; }
if ($min < 10) { $min = "0".$min; }
if ($seg < 10) { $seg="0".$seg; }

print $interfaceDumpLog "######## BEGIN: $timestamp #########\n";
system($tcpCmd);
my $qtdPktFiltered=`tcpdump -r interfaceDump.pcap.count |grep -v "> sv" |grep -v "10.210.39" |wc -l`;
my $qtdPktFiltered=$qtdPktFiltered/1; # Remove the newline from the wc -l
my $qtdPktFilteredSec=$qtdPktFiltered/$colTime;
my $totalRetransFim=`netstat -s |grep "segments retransmited" |cut -d ' ' -f 5`;
my $totalRetrans=$totalRetransFim-$totalRetransInicio;
my $totalRetransSec=$totalRetrans/$colTime;
my $timestamp=$ano."-".$mes."-".$dia." ".$hora.":".$min;
print $interfaceDumpLog "Selected Interface: $intf1 \n";
print $interfaceDumpLog "Polling Periodo: $colTime \n";
print $interfaceDumpLog "Creating a Dump file copy".`cp interfaceDump.pcap interfaceDump.pcap.count`."\n";
print $interfaceDumpLog "Timestamp: ".$ano."/".$mes."/".$dia." ".$hora.":".$min."\n";
print $interfaceDumpLog "Number of filtered packets : $qtdPktFiltered \n";
print $interfaceDumpLog "Number of unfiltered packets $qtdPkt \n";
print $interfaceDumpLog "Number of packets per second (without filter): $qtdPktSec \n";
print $interfaceDumpLog "totalRestransInicio: $totalRetransInicio"." totalRetransFim: $totalRetransFim \n"; # Change this vars to english
print $interfaceDumpLog "totalRetrans on the interval: $totalRetrans \n";
print $interfaceDumpLog "totalRetrans per second: $totalRetransSec \n";
print $interfaceDumpLog "######## END: $timestamp ##########\n";

print $interfaceDumpCsv "$timestamp".";".$qtdPkt.";".$qtdPktSec.";".$qtdPktFiltered.";".$qtdPktFilteredSec.";".$totalRetrans.";".$totalRetransSec."\n";
$checkNum=$checkNum+1;
}
print $interfaceDumpLog "All the executions done for the loop\n";
}
