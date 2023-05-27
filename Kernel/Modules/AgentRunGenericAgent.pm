# --
# Copyright (C) 2018 - 2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentRunGenericAgent;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Output::HTML::Layout
    Kernel::System::Web::Request
    Kernel::System::GenericAgent
);

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $GenericAgentObject = $Kernel::OM->Get('Kernel::System::GenericAgent');

    my @Runnables    = @{ $ConfigObject->Get('TicketMenuRunGenericAgent::Runnable')  || [] };
    my $GenericAgent = $ParamObject->GetParam( Param => 'GA' );

    # check needed stuff
    if ( !grep{ $_ eq $GenericAgent }@Runnables ) {

        # error page
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No valid GenericAgent given!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    my $Run = $GenericAgentObject->JobRun(
        Job          => $GenericAgent,
        OnlyTicketID => $Self->{TicketID},
        UserID       => $Self->{UserID},
    );
    
    return $LayoutObject->Redirect(
        OP => 'Action=AgentTicketZoom&TicketID=' . $Self->{TicketID},
    );
}

1;
