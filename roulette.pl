#!/usr/bin/perl

#
#A wonderful game of innocent gambling
#

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Term::Spinner;

use constant HIGHEST_NUMBER => 36;
use constant LOWEST_NUMBER => 0;
use constant GAME_OVER => 1;
use constant GAME_ON => 0;
use constant WHEELSPIN => 40000;
use constant STARTING_CREDIT => 100;
use constant COLOUR_CHOSEN => 1;
use constant NUMBER_CHOSEN => 0;

#purge stuff
$|=1;

    my $balance = STARTING_CREDIT; #starting credit
    my $currentBet = 0; #amount currently being bet
    my $optionChosen = 0; #number/colour player chooses
    my $colourOfOptionChosen = "NULL"; #colour of the number chosen by player. Not the colour they typed in
    my $colour = "NULL"; #colour roulette ball lands on
    my $gameLoop = GAME_ON; #keeps the game loop going
    my $roulette = 0; #roulette number
    my $numberOrColour = NUMBER_CHOSEN; #splits logic based on if string or int is inputted into optionChosen

#main game routine
$gameLoop = playCheck ($balance, $gameLoop); #prevents game starting with 0 in balance
while ($gameLoop==0){
    print "\nYour current balance is: \$",$balance, "\n";
    $currentBet = placeBet($balance);
    $optionChosen = pickOption;
    $numberOrColour = getNumberOrColour($optionChosen);
    $currentBet = cleanUpBet($currentBet, $balance);
    if($numberOrColour == NUMBER_CHOSEN){
        
        $optionChosen = cleanUpOption($optionChosen);
        $colourOfOptionChosen = getColourOfOptionChosen($optionChosen);
    }
    if (looks_like_number($currentBet)){
        if ($numberOrColour == COLOUR_CHOSEN || looks_like_number($optionChosen)){
            $roulette = spin;
            $colour = getRouletteColour($roulette);
            $balance = winLose ($numberOrColour, $optionChosen, $colour, $balance, $currentBet, $colourOfOptionChosen, $roulette);
        } else {
        print "That wasn't an option, sir. Please try again \n";
        }
    } else {
        print "That's not a numerical amount, sir. Please try again \n";
    }
    $gameLoop = playCheck ($balance, $gameLoop);
}

exit;

sub playCheck{
#if you have no money then you don't get to play
    my $balance = shift;
    my $gameLoop = shift; 

    if ($balance <= 0){
        print "You are out of money. Would you perhaps care for a loan with a reasonably low interest rate?";
        my $gameLoop=GAME_OVER; 
    }
    return $gameLoop;
}

sub placeBet{
#confirms current amount, asks for bet and sorts values
    my $currentBet;

    my $balance = shift;

    print "Place your bets please.\n";
    print "How much do you want to bet?\n";
    $currentBet = <STDIN>;
    $currentBet =~ tr/0-9//dc;

    return $currentBet;
}

sub pickOption{
#player picks a number or colour
    my $optionChosen;

    print "Pick a number to bet from 0 to 36. Type red, black or green to bet on that colour.\n";
    $optionChosen = <STDIN>;
    $optionChosen = uc $optionChosen;
    chomp($optionChosen);

    return $optionChosen;
}

sub getNumberOrColour{
#determines if a number or colour was typed for later checks
    my $numberOrColour;

    my $optionChosen = shift;

    if ($optionChosen eq "RED" || $optionChosen eq "GREEN" || $optionChosen eq "BLACK"){
        $numberOrColour = COLOUR_CHOSEN;
    } else {
        $numberOrColour = NUMBER_CHOSEN;
    }
    return $numberOrColour;
}

sub cleanUpBet{
#alters the bet if invalid numbers have been typed
    my $currentBet = shift;
    my $balance = shift;

    if($currentBet ne ""){
        if ($currentBet == $balance){
            print "Going All in! Max bet placed.\n";
            $currentBet = $balance;
        }
        if ($currentBet > $balance){
            print "What's that? You want to bet all your money, sir? Well go ahead.\n";
            $currentBet = $balance;
        }
        if ($currentBet <= 0){
            print "You are betting nothing. Have fun watching.\n";
            $currentBet = 0;
        }
    }

    return $currentBet;
}

sub cleanUpOption{
#culls any letters or special characters. If player has typed £10, it turns to 10
    my $optionChosen = shift;

    $optionChosen =~ tr/0-9//dc;    
    if($optionChosen ne ""){
        if ($optionChosen > HIGHEST_NUMBER){
            print "Highest number bet!\n";
            $optionChosen = HIGHEST_NUMBER;
        }
        elsif ($optionChosen < LOWEST_NUMBER){
            print "Betting on green!\n";
            $optionChosen = LOWEST_NUMBER;
        }
    }

    return $optionChosen;
}

sub getColourOfOptionChosen{
#determine the colour of the number player has picked
    my $colourOfOptionChosen;

    my $optionChosen = shift;

    if($optionChosen eq ""){
        $colourOfOptionChosen="NULL"; #prevents string not number condition errors if player typed other words into $optionChosen
    }   elsif ($optionChosen==0){
                $colourOfOptionChosen="GREEN";
        } elsif($optionChosen % 2 == 1){
                $colourOfOptionChosen="RED";
        } else {
                $colourOfOptionChosen="BLACK";
        }

    return $colourOfOptionChosen;
}

sub spin{
#roulette table picks random number between 0 and 36, after a dramatic spin
    my $wheelSpin = WHEELSPIN;
    my $roulette;

        print"Spinning Wheel\n";
        my $spinner = Term::Spinner->new();
        while($wheelSpin > 0) {
        $spinner->advance();
        $wheelSpin--;
        }
        undef $spinner; # clears final spinner output by default.
        
        $roulette=int(rand(37)); #spin the wheel to get a number between 0-36
        return $roulette;

    }

sub getRouletteColour{
#determines the colour of the number the roulette ball lands on
    my $colour = "NULL";

    my $roulette = shift;

        if ($roulette==0){ #determines colour of number roulette ball has landed on
            $colour="GREEN";
        } elsif($roulette % 2 == 1){
            $colour="RED";
        } else {
            $colour="BLACK";
        }

        print "Ball lands on ", $roulette," ", $colour,"\n";


    return $colour;
}


sub winLose{
#if number is loser current bet is deducted from balance. If number is winner, increase balance by winnings
    my $numberOrColour = shift;
    my $optionChosen = shift;
    my $colour = shift;
    my $balance = shift;
    my $currentBet = shift;
    my $colourOfOptionChosen = shift;
    my $roulette = shift;

        if ($numberOrColour == COLOUR_CHOSEN){
            print "You have bet on ", $optionChosen,"\n";
            if ($optionChosen eq $colour){  
                print "That means... Your colour wins!\n";
                $balance += $currentBet;            
            } else {
                print "That means... You lose!\n";
                $balance -= $currentBet;
            }
        }
        elsif ( $numberOrColour == NUMBER_CHOSEN){
            print "You have bet on ", $optionChosen," ", $colourOfOptionChosen,"\n";
            if ($roulette == $optionChosen){
                print "That means... Your number wins!\n";
                $balance += $currentBet * 35;
            } else {
                print "That means... You lose!\n";
                $balance -= $currentBet;
            }
        }

    return $balance;
    }

