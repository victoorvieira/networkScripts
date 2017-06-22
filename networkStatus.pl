#!/usr/bin/perl

if (not defined $ARGV[0]){

print "USAGE: ./interfaceStatus.pl INTERFACE_NAME\n";
print "ex: ./interfaceStatus.pl eth0\n";

}

else {

my $intf1=$ARGV[0];

# Polling period
my $pollingPeriod="300";

#variaveis para utilizacao de banda
my $RXbytes1=`ifconfig $intf1 |grep "RX bytes" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $TXbytes1=`ifconfig $intf1 |grep "RX bytes" |cut -d ' '  -f 16-17 |cut -d ':' -f 2`;
my $sumBytes1=$RXbytes1+$TXbytes1;
my $ub1=$sumBytes1;

#variaveis para total de pacotes
my $RXPackets1=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $TXPackets1=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $sumPackets1=$RXPackets1+$TXPackets1;
my $totalPackets1=$sumPackets1;

#variaveis para qtd erros
my $RXErrors1=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 13 |cut -d ':' -f 2`;
my $TXErrors1=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 13 |cut -d ':' -f 2`;
my $sumErrors1=$RXErrors1+$TXErrors1;
my $totalErrors1=$sumErrors1;

#variaveis para drop
my $RXDrop1=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 14 |cut -d ':' -f 2`;
my $TXDrop1=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 14 |cut -d ':' -f 2`;
my $sumDrop1=$RXDrop1+$TXDrop1;
my $totalDrop1=$sumDrop1;

# abrir arquivo csv
open($outputCsv, ">>", "$intf1"."_status.csv") or die "Problema ao gerar o csv";

#imprimir cabecalho do csv
print $outputCsv "timestamp;utilizacaoBanda(Mbits/sec);totalPktSec;totalDropPkts;totalErrors;totalTelnet\n";

close $outputCsv;

while (TRUE) {

open($outputCsv, ">>", "$intf1"."_status.csv") or die "Problema ao gerar o csv";
open($outputLog, ">>", "$intf1"."_status.log") or die "Problema ao gerar o log";

my ($seg,$min,$hora,$dia,$mes,$ano)=localtime(time);
$ano=$ano+1900;
$mes=$mes+1;
if ($mes < 10) { $mes = "0".$mes; }
if ($dia < 10) { $dia = "0".$dia; }
if ($hora < 10) { $hora = "0".$hora; }
if ($min < 10) { $min = "0".$min; }
if ($seg < 10) { $seg="0".$seg; }

#variavel para total de conexoes telnet
my $totalTelnet=`netstat -ut |grep telnet |grep ESTABLISHED |wc -l`;

print $outputLog $ano."-".$mes."-".$dia." ".$hora.":".$min.":".$seg;
my $timestamp=$ano."-".$mes."-".$dia." ".$hora.":".$min;

print $outputLog "\nub inicial $intf1: $ub1\n";
print $outputLog "total pkt inicial $intf1: $totalPackets1\n";
print $outputLog "err inicial $intf1: $totalErrors1\n";
print $outputLog "drop inicial $intf1: $totalDrop1\n";

sleep $pollingPeriod;

my $RXbytes2=`ifconfig $intf1 |grep "RX bytes" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $TXbytes2=`ifconfig $intf1 |grep "RX bytes" |cut -d ' '  -f 16-17 |cut -d ':' -f 2`;
my $sumBytes2=$RXbytes2+$TXbytes2;

my $RXPackets2=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $TXPackets2=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 11-12 |cut -d ':' -f 2`;
my $sumPackets2=$RXPackets2+$TXPackets2;

my $RXErrors2=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 13 |cut -d ':' -f 2`;
my $TXErrors2=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 13 |cut -d ':' -f 2`;
my $sumErrors2=$RXErrors2+$TXErrors2;

my $RXDrop2=`ifconfig $intf1 |grep "RX packets" |cut -d ' '  -f 14 |cut -d ':' -f 2`;
my $TXDrop2=`ifconfig $intf1 |grep "TX packets" |cut -d ' '  -f 14 |cut -d ':' -f 2`;
my $sumDrop2=$RXDrop2+$TXDrop2;

my $ub2=$sumBytes2;
my $totalPackets2=$sumPackets2;
my $totalErrors2=$sumErrors2;
my $totalDrop2=$sumDrop2;

print $outputLog "ub depois do polling $intf1: $ub2\n";
print $outputLog "pacotes depois do polling $intf1: $totalPackets2\n";
print $outputLog "err dpeois do polling $intf1: $totalErrors2\n";
print $outputLog "drops depois do polling $intf1: $totalDrop2\n";

my $ubDiff=$ub2-$ub1;
my $pktDiff=$totalPackets2-$totalPackets1;
my $errDiff=$totalErrors2-$totalErrors1;
my $dropDiff=$totalDrop2-$totalDrop1;

$ub1=$ub2;
$totalPackets1=$totalPackets2;
$totalErrors1=$totalErrors2;
$totalDrop1=$totalDrop2;

#converter coleta de pacotes para pacotes por segundo
my $totalPacketsSec=sprintf("%.2f",$pktDiff/$pollingPeriod);

#converter coleta de banda para Mb/s
my $totalBytesSec=sprintf("%.2f",$ubDiff/$pollingPeriod);
my $totalBitsSec=sprintf("%.2f",$totalBytesSec*8);
my $totalMbitsSec=sprintf("%.2f",$totalBitsSec/1048576);

#print $outputLog "Banda Diff: $ubDiff\n";
#print $outputLog "Banda b/s: $totalBitsSec\n";
#print $outputLog "Pacotes Diff: $pktDiff\n";
#print $outputLog "Pacotes/segundo: $totalPacketsSec\n";
#print $outputLog "Erros Diff: $errDiff\n";
#print $outputLog "Drop Diff: $dropDiff\n";
#print $outputLog "Total Telnet: $totalTelnet\n";

#falta colocar o valor em Mbits/sec
#timestamp;utilBanda;totalPkt;dropPkts;totalErrors;totalTelnet
print $outputCsv $timestamp.";".$totalMbitsSec.";".$totalPacketsSec.";".$dropDiff.";".$errDiff.";".$totalTelnet;

close $outputCsv;
close $outputLog;
} #final do while
} #final do else
