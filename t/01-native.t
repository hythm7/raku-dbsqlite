#!/usr/bin/env raku
use Test;
use Test::When <extended>;

use DB::SQLite::Native;

plan 15;

ok DB::SQLite::Native.libversion, 'libversion';

is DB::SQLite::Native.threadsafe, 1, 'threadsafe';

isa-ok my $sl = DB::SQLite::Native.open(':memory:'),
    DB::SQLite::Native, 'native database handle';

isa-ok my $sf = DB::SQLite::Native.open('test.sqlite3', flags => SQLITE_OPEN_READONLY),
    DB::SQLite::Native, 'native database handle with flags';

is $sl.busy-timeout(10000), 0, 'set busy timeout';

isa-ok my $st = $sl.prepare('select $mine as a'),
  DB::SQLite::Native::Statement, 'native statement handle';

is $st.count, 1, 'count is 1 column returned';

is $st.name(0), 'a', 'name of column 0';

lives-ok { $st.bind('mine', 'this') }, 'bind text';

is $st.step, +SQLITE_ROW, 'step';

is $st.type(0), +SQLITE_TEXT, 'text returned in column 0';

is $st.text(0), 'this', 'returned text';

lives-ok { $st.finalize }, 'finalize statement handle';

lives-ok { $sl.close }, 'close database handle';

is DB::SQLite::Native.memory-used, 0, 'All handles deleted';

done-testing;
