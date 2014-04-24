#!/opt/perl

use Mojolicious::Lite;

helper setup_valid => sub {
    my $self  = shift;
    my $topics = shift;

    my $v = $self->validation;

    foreach my $topic (@{$topics}) {
        if ("login" eq $topic) {
            $v->required("login");
            $v->size(5, 10);
            $v->like(qr/^admin$/);
        }
        elsif ("password" eq $topic) {
            $v->required("password");
            $v->size(8, 16);
            $v->like(qr/[[:lower:]]/);  # at least one character
            $v->like(qr/[[:upper:]]/);  # at least one character
            $v->like(qr/[[:digit:]]/);  # at least one character
        }
    }
};

get '/' => sub {
    my $self = shift;

    if ($self->session->{have_user}) {
        $self->redirect_to("/dashboard");
    }
    else {
        $self->redirect_to("/login");
    }
};

any '/login' => sub {
    my $self = shift;

    $self->setup_valid([qw(login password)]);

    my $v = $self->validation;

    return $self->render unless $v->has_data;

    my @names = $v->param;
    foreach my $name (@names) {
        $self->stash($name, $v->param($name));
    }

    if ($self->validation->has_error) {
        $self->stash("error", "Incorrect credentials");
        $self->render;
        return;
    }

    $self->session->{have_user} = 1;
    $self->redirect_to("/");

    return;
};

get '/dashboard' => sub {
    my $self = shift;

    return;
};

get '/logout' => sub {
    my $self = shift;

    $self->session(expires => 1);
    $self->redirect_to("/");

    return;
};

app->log->level("debug");

#plugin tt_renderer => {template_options => {CACHE_SIZE => 0, COMPILE_EXT => undef, COMPILE_DIR => undef}};

app->renderer->default_handler('tt');

app->secret("For validation");

app->start;

__DATA__

@@ login.html.tt
<!DOCTYPE html>
<html>
<head>
    <title>Valid</title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css" />
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>

    <script>
        $(document).bind("mobileinit", function(){
            $.mobile.ajaxEnabled = false;
        });
    </script>

    <script src="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.js"></script>
</head>
<body>

<div data-role="dialog" data-close-btn="none">

    <div data-role="header" data-theme="d">
        <h1>Login</h1>
    </div>

    <div data-role="content">
        [% IF error || c.flash('error') %]
        <p><span> <a data-inline="true" data-iconpos="notext" data-icon="alert" data-role="button" class="ui-icon-alt ui-btn ui-shadow ui-btn-corner-all ui-btn-inline ui-btn-icon-notext ui-btn-up-e" href="index.html" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="e"><span class="ui-btn-inner"><span class="ui-btn-text">Alert</span><span class="ui-icon ui-icon-alert ui-icon-shadow"></span></span></a>
        </span> [% error || c.flash('error') %] </p>
        [% END %]

        [% IF success || c.flash('success') %]
        <p><span> <a data-inline="true" data-iconpos="notext" data-icon="check" data-role="button" class="ui-icon-alt ui-btn ui-shadow ui-btn-corner-all ui-btn-inline ui-btn-icon-notext ui-btn-up-e" href="index.html" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="e"><span class="ui-btn-inner"><span class="ui-btn-text">Success</span><span class="ui-icon ui-icon-check ui-icon-shadow"></span></span></a>
        </span> [% success || c.flash('success')  %] </p>
        [% END %]

        [% IF info || c.flash('info') %]
        <p><span> <a data-inline="true" data-iconpos="notext" data-icon="info" data-role="button" class="ui-icon-alt ui-btn ui-shadow ui-btn-corner-all ui-btn-inline ui-btn-icon-notext ui-btn-up-e" href="index.html" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="e"><span class="ui-btn-inner"><span class="ui-btn-text">Info</span><span class="ui-icon ui-icon-info ui-icon-shadow"></span></span></a>
        </span> [% info || c.flash('info') %] </p>
        [% END %]

            <div data-role="popup" id="popupLogin" class="ui-content" data-theme="e" style="max-width:350px;">
                              <p>Try logging in as <strong>admin</strong></p>
                              </div>

            <div data-role="popup" id="popupPassword" class="ui-content" data-theme="e" style="max-width:350px;">
                              <p>You need 8-16 characters, and one upper-case, one lower-case, and one digit character. </p>
                              </div>

        <form data-ajax=false action="/login" method="post">
            [% IF c.validation.has_data && c.validation.has_error('login') %]
                <div class="ui-grid-a">
                    <div class="ui-block-a" style="width: 8%;"><a href="#popupLogin" data-rel="popup" data-role="button" class="ui-icon-alt" data-inline="true" data-transition="pop" data-icon="info" data-theme="e" data-iconpos="notext">Learn more</a></div>
                    <div class="ui-block-b" style="width: 92%;"><input name="login" id="login" placeholder="Login" value="[% login | html %]" type="text" autocapitalize="off"></div>
                </div>
            [% ELSE %]
                <div class="ui-grid-solo">
                    <div class="ui-block-a"><input name="login" id="login" placeholder="Login" value="[% login | html %]" type="text" autocapitalize="off"></div>
                </div>
            [% END %]

            [% IF c.validation.has_data && c.validation.has_error('password') %]
                <div class="ui-grid-a">
                    <div class="ui-block-a" style="width: 8%;"><a href="#popupPassword" data-rel="popup" data-role="button" class="ui-icon-alt" data-inline="true" data-transition="pop" data-icon="info" data-theme="e" data-iconpos="notext">Learn more</a></div>
                    <div class="ui-block-b" style="width: 92%;"><input name="password" id="password" placeholder="Password" value="[% password | html %]" autocapitalize="off" type="password"></div>
                </div>
            [% ELSE %]
                <div class="ui-grid-solo">
                    <div class="ui-block-a"><input name="password" id="password" placeholder="Password" value="[% password | html %]" autocapitalize="off" type="password"></div>
                </div>
            [% END %]

            <div class="ui-grid-solo">
                <div class="ui-block-a"><input value="Login" data-theme="b" type="submit"></div>
            </div>
        </form>
    </div>
</div>

</body>
</html>

@@ dashboard.html.tt
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css" />
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script>
        $(document).bind("mobileinit", function(){
              $.mobile.ajaxEnabled = false;
        });
    </script>
    <script src="http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.js"></script>
</head>
<body>

<div data-role="dialog" data-close-btn="none">

    <div data-role="header" data-theme="d">
        <h1>Dashboard</h1>
    </div>

    <div data-role="content">
        <p><span> <a data-inline="true" data-iconpos="notext" data-icon="check" data-role="button" class="ui-icon-alt ui-btn ui-shadow ui-btn-corner-all ui-btn-inline ui-btn-icon-notext ui-btn-up-e" href="index.html" data-corners="true" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-theme="e"><span class="ui-btn-inner"><span class="ui-btn-text">Success</span><span class="ui-icon ui-icon-check ui-icon-shadow"></span></span></a>
        </span> Woohoo! </p>
        <br />
        <a href="/logout" data-ajax="false" data-role="button" data-theme="b">Logout</a>
    </div>
</div>

</body>
</html>
