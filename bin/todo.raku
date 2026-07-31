#!/usr/bin/env rakupp

my $resume-prefix = 'codex resume ';

sub home-dir(--> Str) {
    %*ENV<HOME> // fatal('HOME is not set')
}

sub default-todo-file(--> Str) {
    %*ENV<TODO_FILE> // (home-dir() ~ '/.todo')
}

sub default-codex-home(--> Str) {
    %*ENV<CODEX_HOME> // (home-dir() ~ '/.codex')
}

sub expand-home(Str $path --> Str) {
    return home-dir() ~ $path.substr(1) if $path.starts-with('~/');
    $path
}

sub fatal(Str $message, Int $status = 2) {
    note 'todo: ' ~ $message;
    exit $status;
}

sub find-tool(Str $name --> Str) {
    for (%*ENV<PATH> // '').split(':') -> $directory {
        next unless $directory.chars;
        my $candidate = ($directory ~ '/' ~ $name).IO;
        return $candidate.Str if $candidate.f;
    }
    ''
}

sub capture(Str $program, *@arguments --> Hash) {
    my $process = run $program, |@arguments, :out, :err;
    my $stdout = $process.out.slurp-rest;
    my $stderr = $process.err.slurp-rest;
    %(
        ok     => $process.exitcode == 0,
        status => $process.exitcode,
        stdout => $stdout,
        stderr => $stderr,
    )
}

sub valid-session-id(Str $candidate --> Bool) {
    return False unless $candidate.chars == 36;

    for 8, 13, 18, 23 -> $offset {
        return False unless $candidate.substr($offset, 1) eq '-';
    }

    my $hex = $candidate.subst('-', '', :g).lc;
    return False unless $hex.chars == 32;

    for $hex.comb -> $character {
        return False unless '0123456789abcdef'.contains($character);
    }

    True
}

sub sql-string(Str $value --> Str) {
    q['] ~ $value.subst(q['], q[''], :g) ~ q[']
}

sub state-db-version(IO::Path $path --> Int) {
    my $name = $path.basename;
    my $number = $name.substr(6, $name.chars - 13);
    $number.Int
}

sub state-databases(Str $codex-home --> Array) {
    my $home = expand-home($codex-home).IO.absolute;
    return [] unless $home.d;

    dir($home)
        .grep({
            my $name = .basename;
            $name ~~ /^ 'state_' <[0..9]>+ '.sqlite' $/
        })
        .map({ .IO })
        .sort({ state-db-version($^b) <=> state-db-version($^a) })
        .Array
}

sub git-root(Str $directory --> Str) {
    my $git = find-tool('git');
    return '' unless $git.chars;

    my %result = capture(
        $git,
        '-C', $directory,
        'rev-parse', '--show-toplevel',
    );

    %result<ok> ?? %result<stdout>.trim !! ''
}

sub query-session(
    Str $sqlite,
    IO::Path $database,
    Str $directory,
    --> Str
) {
    my $sql = qq:to/SQL/;
        SELECT id
        FROM threads
        WHERE archived = 0
          AND cwd = {sql-string($directory)}
        ORDER BY updated_at DESC, id DESC
        LIMIT 1;
        SQL

    my %result = capture(
        $sqlite,
        '-readonly', '-batch', '-noheader',
        $database.Str,
        $sql,
    );

    return '' unless %result<ok>;

    my $id = %result<stdout>.trim;
    valid-session-id($id) ?? $id !! ''
}

sub discover-session(Str $directory, Str $codex-home --> Str) {
    my $sqlite = find-tool('sqlite3');
    fatal('sqlite3 was not found in PATH') unless $sqlite.chars;

    my @databases = state-databases($codex-home);
    fatal(
        'no Codex state database was found under '
            ~ expand-home($codex-home)
            ~ '; pass --session=UUID to override discovery'
    ) unless @databases.elems;

    my $cwd = expand-home($directory).IO.absolute;
    fatal('directory does not exist: ' ~ $cwd.Str) unless $cwd.d;

    my @directories = $cwd.Str;
    my $root = git-root($cwd.Str);
    @directories.push($root) if $root.chars && $root ne $cwd.Str;

    for @directories -> $candidate-directory {
        for @databases -> $database {
            my $id = query-session(
                $sqlite,
                $database,
                $candidate-directory,
            );
            return $id if $id.chars;
        }
    }

    fatal(
        'no active Codex session matches '
            ~ $cwd.Str
            ~ '; run from the session directory or pass --session=UUID'
    )
}

sub flush-entry(\entries, \current) {
    return unless current<title>:exists;

    my $title = (current<title> // '').Str.trim;
    my $resume = (current<resume> // '').Str.trim;
    my @notes = (current<notes> // []).Array;

    fatal('an entry has an empty title') unless $title.chars;
    fatal('entry "' ~ $title ~ '" has no resume command') unless $resume.chars;
    fatal('entry "' ~ $title ~ '" has an invalid resume command')
        unless $resume.starts-with($resume-prefix)
            && valid-session-id($resume.substr($resume-prefix.chars));

    entries.push(%(
        title  => $title,
        resume => $resume,
        notes  => @notes.Array,
    ));

    current = ();
}

sub load-entries(Str $file --> Array) {
    my $path = expand-home($file).IO.absolute;
    return [] unless $path.e;

    my @entries;
    my %current;
    my $reading-notes = False;

    for slurp($path).lines -> $line {
        if $line.starts-with('title:') {
            flush-entry(@entries, %current);
            %current = (
                title  => $line.substr(6).trim,
                resume => '',
                notes  => [],
            );
            $reading-notes = False;
            next;
        }

        if %current<title>:exists && $line.starts-with('resume:') {
            %current<resume> = $line.substr(7).trim;
            $reading-notes = False;
            next;
        }

        if %current<title>:exists && $line.trim eq 'notes:' {
            $reading-notes = True;
            next;
        }

        if $reading-notes && $line.starts-with('  ') {
            %current<notes>.push($line.substr(2));
            next;
        }

        if $line.trim eq '' {
            flush-entry(@entries, %current);
            $reading-notes = False;
            next;
        }

        if $line.starts-with('|______>') {
            if %current<title>:exists {
                %current<notes>.push($line.substr(8).trim);
            }
            next;
        }

        my $marker = ' codex resume ';
        my $offset = $line.index($marker);
        if $offset.defined {
            flush-entry(@entries, %current);
            %current = (
                title  => $line.substr(0, $offset).trim,
                resume => $resume-prefix
                    ~ $line.substr($offset + $marker.chars).trim,
                notes  => [],
            );
            $reading-notes = False;
            next;
        }

        if $reading-notes && %current<title>:exists {
            %current<notes>.push($line.trim);
        }
    }

    flush-entry(@entries, %current);

    my %seen;
    for @entries -> %entry {
        my $key = %entry<title>.lc;
        fatal('duplicate title in todo file: ' ~ %entry<title>)
            if %seen{$key}:exists;
        %seen{$key} = True;
    }

    @entries
}

sub render-entry(%entry --> Str) {
    my @lines = (
        'title: ' ~ %entry<title>,
        'resume: ' ~ %entry<resume>,
    );

    my @notes = (%entry<notes> // []).Array;
    if @notes.elems {
        @lines.push('notes:');
        @lines.append(@notes.map({ '  ' ~ $_ }));
    }

    @lines.join("\n")
}

sub render-file(@entries --> Str) {
    return '' unless @entries.elems;
    @entries.map({ render-entry($_) }).join("\n\n") ~ "\n"
}

sub write-entries(Str $file, @entries) {
    my $path = expand-home($file).IO.absolute;
    my $parent = $path.dirname.IO;
    mkdir $parent unless $parent.d;

    my $cp = find-tool('cp');
    if $path.e && $cp.chars {
        my $backup = $path.Str ~ '.bak';
        my $copy = run $cp, '-p', $path.Str, $backup;
        fatal('could not write backup: ' ~ $backup) if $copy.exitcode != 0;
    }

    my $temporary = $path.Str ~ '.tmp.' ~ $*PID;
    spurt $temporary, render-file(@entries);

    my $chmod = find-tool('chmod');
    if $chmod.chars {
        my $permission = run $chmod, '600', $temporary;
        fatal('could not set permissions on temporary todo file')
            if $permission.exitcode != 0;
    }

    my $mv = find-tool('mv');
    fatal('mv was not found in PATH') unless $mv.chars;

    my $move = run $mv, '-f', $temporary, $path.Str;
    fatal('could not replace ' ~ $path.Str) if $move.exitcode != 0;
}

sub find-entry(@entries, Str $needle --> Hash) {
    my $query = $needle.trim.lc;
    fatal('search text cannot be empty') unless $query.chars;

    my @exact = @entries.grep({ $_<title>.lc eq $query });
    return @exact[0] if @exact.elems == 1;
    fatal('duplicate exact matches for: ' ~ $needle) if @exact.elems > 1;

    my @partial = @entries.grep({ $_<title>.lc.contains($query) });
    return @partial[0] if @partial.elems == 1;
    fatal('no todo entry matches: ' ~ $needle) unless @partial.elems;

    fatal(
        'ambiguous search "'
            ~ $needle
            ~ '": '
            ~ @partial.map(*<title>).join(', ')
    )
}

sub copy-to-clipboard(Str $text) {
    my $pbcopy = find-tool('pbcopy');
    fatal('pbcopy was not found in PATH') unless $pbcopy.chars;

    my $process = run $pbcopy, :in;
    $process.in.print($text);
    $process.in.close;
    fatal('pbcopy failed', 1) if $process.exitcode != 0;
}

sub show-entry(%entry) {
    say %entry<title>;
    say '  ' ~ %entry<resume>;
    for (%entry<notes> // []).Array -> $note {
        say '  ' ~ $note;
    }
}

sub upsert-entry(
    \entries,
    Str $title,
    Str $resume,
    @notes,
) {
    for entries.kv -> $index, %entry {
        if %entry<title>.lc eq $title.lc {
            entries[$index] = %(
                title  => $title,
                resume => $resume,
                notes  => @notes.Array,
            );
            return;
        }
    }

    entries.push(%(
        title  => $title,
        resume => $resume,
        notes  => @notes.Array,
    ));
}

sub MAIN(
    Str :$title,
    Str :$search,
    Str :$delete,
    Str :$notes,
    Str :$session,
    Str :$directory = $*CWD.Str,
    Str :$file = default-todo-file(),
    Str :$codex-home = default-codex-home(),
    Bool :$clipboard = False,
    Bool :$list = False,
    *@words,
) {
    my $mode-count = ($title.defined ?? 1 !! 0)
        + ($search.defined ?? 1 !! 0)
        + ($delete.defined ?? 1 !! 0)
        + ($list ?? 1 !! 0);

    fatal('choose exactly one of --title, --search, --delete, or --list')
        unless $mode-count == 1;
    fatal('--clipboard requires --search') if $clipboard && !$search.defined;
    fatal('--session is valid only with --title')
        if $session.defined && !$title.defined;
    fatal('unexpected positional text: ' ~ @words.join(' '))
        if @words.elems && !$title.defined;

    my @entries = load-entries($file);

    if $list {
        for @entries -> %entry {
            say %entry<title>;
        }
        return;
    }

    if $search.defined {
        my %entry = find-entry(@entries, $search);
        if $clipboard {
            copy-to-clipboard(%entry<resume>);
            note 'copied ' ~ %entry<title>;
        }
        else {
            show-entry(%entry);
        }
        return;
    }

    if $delete.defined {
        my %entry = find-entry(@entries, $delete);
        @entries = @entries.grep({ $_<title> ne %entry<title> }).Array;
        write-entries($file, @entries);
        say 'deleted ' ~ %entry<title>;
        return;
    }

    my $clean-title = $title.trim;
    fatal('title cannot be empty') unless $clean-title.chars;
    fatal('title cannot contain a newline') if $clean-title.contains("\n");

    my $id;
    if $session.defined {
        $id = $session.trim;
        fatal('invalid Codex session id: ' ~ $id) unless valid-session-id($id);
    }
    else {
        $id = discover-session($directory, $codex-home);
    }

    my $notes-were-supplied = $notes.defined || @words.elems;
    my $note-text = $notes.defined ?? $notes.Str !! '';
    if @words.elems {
        $note-text ~= ($note-text.chars ?? ' ' !! '') ~ @words.join(' ');
    }

    my @entry-notes;
    if $notes-were-supplied {
        @entry-notes = $note-text.lines.map(*.trim).grep(*.chars).Array;
    }
    else {
        my @existing = @entries.grep({ $_<title>.lc eq $clean-title.lc });
        @entry-notes = @existing.elems
            ?? (@existing[0]<notes> // []).Array
            !! [];
    }

    my $resume = $resume-prefix ~ $id;
    upsert-entry(@entries, $clean-title, $resume, @entry-notes);
    write-entries($file, @entries);

    say 'saved ' ~ $clean-title;
    say '  ' ~ $resume;
}
