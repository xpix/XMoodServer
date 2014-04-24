use Device::SerialPort;
use Time::HiRes qw(usleep);
my $port = new Device::SerialPort("/dev/rfcomm1"); 
$port->user_msg(ON); 
$port->baudrate(9600); 
$port->parity("none"); 
$port->databits(8); 
$port->stopbits(1); 
#$port->handshake("xoff"); 
$port->write_settings;

$port->lookclear; 
$port->write(shift."\r\n");
my $answer = $port->lookfor;

for(my $i=0;$i<255;$i++){
   usleep(100000);
   $port->write("b $i\r\n");
   $answer = $port->lookfor;
   print $answer."\n";
}

exit;

