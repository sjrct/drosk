:- use_module(library(filesex)).
:- [boot/main, kernel/main].

% The predicate that builds the system
build :- boot, kernel.

% The rule used to build NASM assembly files
nasm(Out, In, Args, Extra) :-
	remake3(Out, In, Extra),
	lwrite([' nasm ', Out]),
	lshell(['nasm -o ', Out, ' ', In, ' ', Args]).

% The rule used to build C files
cc(Out, In, Args, [Extra]) :-
	remake3(Out, In, Extra),
	lwrite([' cc ', Out]),
	lshell(['cc -o ', Out, ' ', In, ' ', Args]).

% Adds a prefix to each string in the list
prefix(_, [], []).
prefix(Prefix, [X | Xs], [Y | Ys]) :-
	string_concat(Prefix, X, Y),
	prefix(Prefix, Xs, Ys).

% Adds a suffix to each string in the list
suffix(_, [], []).
suffix(Suffix, [X | Xs], [Y | Ys]) :-
	string_concat(Suffix, X, Y),
	suffix(Suffix, Xs, Ys).

% Concatenates a list into a string
concat([], '').
concat([Prefix | Ls], Str) :-
	concat(Ls, Suffix),
	string_concat(Prefix, Suffix, Str).

% Convience function that acts like write/1, but concats list first
lwrite(Ls) :-
	concat(Ls, Cmd),
	writeln(Cmd).

% Convience function that acts like shell/1, but concats list first
lshell(Ls) :-
	concat(Ls, Cmd),
	shell(Cmd).

% This will return true if What needs to be remade with respect to the given file list
remake(Obj, _) :-
	\+ exists(Obj).
remake(Obj, [D | Deps]) :-
	\+ exists(D);
	newer(D, Obj);
	remake(Obj, Deps).

% Convience predicate that wraps to remake
remake3(Out, In, Extra) :-
	append(Extra, [In], Deps),
	remake(Out, Deps).

% True if file A is newer (modified) than file B
newer(A, B) :-
	set_time_file(A, [modified(C)], []),
	set_time_file(B, [modified(D)], []),
	C > D.

% Returns true if F is a file or directory that exists
exists(F) :- exists_file(F).
exists(F) :- exists_directory(F).
