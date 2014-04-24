#!/usr/bin/perl
use strict;
use warnings;

# please use "sudo hciconfig hci0 up" 
# if BT Serial Device not running

use Mojolicious::Lite;
use Device::SerialPort;

my $port = new Device::SerialPort("/dev/rfcomm1"); 
$port->user_msg("ON"); 
$port->baudrate(9600); 
$port->parity("none"); 
$port->databits(8); 
$port->stopbits(1); 
#$port->handshake("xoff"); 
$port->write_settings;
$port->lookclear; 

$port->write("A\r\n");
my $answer = $port->lookfor;


# Simple plain text response
get '/' => {text => 'I ? Mojolicious!'};

# The main Page
get '/dashboard' => sub {
    my $self = shift;
    return;
};

get '/preferences' => sub {
    my $self = shift;
    return;
};

get '/colors' => sub {
    my $self = shift;
    return;
};

# Route associating "/xmood" with template in DATA section
get '/xmood' => sub {
        my $self = shift;

        my $cmd = $self->param('command') || 'n';
        my @par  = split(/\,/,$self->param('param') || '1');

        $port->write(sprintf("%s %s\r\n", $cmd, join(' ', @par)));
        my $answer = $port->lookfor;

        return $self->render_json({answer => $answer});
};

app->secret("For xmood");

app->start;
