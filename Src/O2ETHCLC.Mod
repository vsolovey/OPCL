(*
	Command line wrapper for ETH Oberon compiler (Windows).
	This version of 'Compiler' module was reduced to compile from file only.
	Eugene Shcherbatyuk (ugns@mail.ru)
	Nov-Dec 2002
*)

(* ETH Oberon, Copyright 2000 ETH Zuerich Institut fuer Computersysteme,
	ETH Zentrum, CH-8092 Zuerich.
	Refer to the "General ETH Oberon System Source License" contract
	available at: http://www.oberon.ethz.ch/ *)

MODULE O2ETHCLC;
	IMPORT
		FileDir,
		OPP, OPB, OPV, OPT, OPS, OPC, OPL, OPO, OPM,
		Modules, Texts, Console, CmdLine;

	CONST
		module = OPS.module;
		ident = OPS.ident;
		period = OPS.period;	(* symbols *)

	VAR
		W: Texts.Writer;

	(***********************************)
	PROCEDURE About;
	BEGIN
		Console.WriteLn;
		Console.WriteString("Command line version of the ETH Oberon Plugin for");	Console.WriteLn;
		Console.WriteString("Windows  Release 2.4  Oberon  Portable  Compiler.");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("  Compiler by: Team of the Institute for Computer");	Console.WriteLn;
		Console.WriteString("  Systems  of  ETH  Zuerich  (www.oberon.ethz.ch)");	Console.WriteLn;
		Console.WriteString("  Wrapper  by: E.V. Shcherbatyuk   (ugns@mail.ru)");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("Run 'O2ETHCLC /?' for this information.");	Console.WriteLn;
		Console.WriteString("Run 'O2ETHCLC /*' for help on compiler options.");	Console.WriteLn;
		Console.WriteString("Run 'O2ETHCLC [/path] file [@options]' to compile.");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("path - path to read and store object files (with trailing '\')");	Console.WriteLn;
		Console.WriteString("@options - compiler options to be turned on/off");	Console.WriteLn;
	END About;

	(***********************************)
	PROCEDURE AboutOptions;
	BEGIN
		Console.WriteString("Run 'O2ETHCLC [/path] file [@options]' to compile.");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("path - path to read and store object files (with trailing '\')");	Console.WriteLn;
		Console.WriteString("@options - compiler options to be turned on/off");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("Available options are:");	Console.WriteLn;
		Console.WriteString("f,F - prevent/allow creation of files");	Console.WriteLn;
		Console.WriteString("n,N - prevent/allow generation of new Symbol table");	Console.WriteLn;
		Console.WriteString("e,E - prevent/allow extension of symbol table");	Console.WriteLn;
		Console.WriteString("s,S - prevent/allow compilation of modules importing SYSTEM");	Console.WriteLn;
		Console.WriteString("w,W - hide/display warning messages");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("p,P - don't/do initialize pointers to NIL");	Console.WriteLn;
		Console.WriteString("z,Z - don't/do zero all the stack (only if ptrinit)");	Console.WriteLn;
		Console.WriteString("a,A - don't/do evaluate ASSERT functions");	Console.WriteLn;
		Console.WriteString("x,X - don't/do check indexes");	Console.WriteLn;
		Console.WriteString("t,T - don't/do check types");	Console.WriteLn;
		Console.WriteString("v,V - don't/do check overflows");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("3 - compile Active Oberon");	Console.WriteLn;
		Console.WriteString("2 - compile Oberon-2");	Console.WriteLn;
		Console.WriteString("1 - compile Oberon-1");	Console.WriteLn;
		Console.WriteLn;
		Console.WriteString("Default options are FneSwPZAXTv3");
	END AboutOptions;

	(***********************************)
	PROCEDURE GetOptions(VAR path, name, opts: ARRAY OF CHAR):BOOLEAN;
		CONST
			NoParameters = "No parameters specified";
			NoPath = "No path specified";
			NoFile = "No file specified";
			NoOptions = "No options specified";
			InvalidOptions = "Invalid options: '@' expected";
			SlashQuestionForHelp = "Run 'O2ETHCLC /?' for help";
		VAR i, j, k: LONGINT; ch: CHAR;
	BEGIN
		path[0] := 0X;	name[0] := 0X;	opts[0] := 0X;	i := 0;
		(* Skip executable pathname *)
		ch := CmdLine.text[i];
		WHILE (ch # " ") & (ch # 0X) DO
			INC(i);
			ch := CmdLine.text[i];
		END;
		j := i;
		IF ch = 0X THEN
			Console.WriteString(NoParameters);	Console.WriteLn;
			Console.WriteString(SlashQuestionForHelp);	Console.WriteLn;
			RETURN FALSE;
		END;
		(* look for path or switches *)
		WHILE (ch # "/") & (ch # 0X) DO
			INC(i);
			ch := CmdLine.text[i];
		END;
		IF ch = "/" THEN
			INC(i);
			ch := CmdLine.text[i];
			IF    ch = "?"  THEN About; RETURN FALSE;
			ELSIF ch = "*"  THEN AboutOptions; RETURN FALSE;
			ELSIF ch <= " " THEN
				Console.WriteString(NoPath);	Console.WriteLn;
				Console.WriteString(SlashQuestionForHelp);	Console.WriteLn;
				RETURN FALSE;
			ELSE
				k := 0;
				WHILE (ch > " ") & (k < LEN(path) - 1) DO
					path[k] := ch;	INC(k);
					INC(i);	ch := CmdLine.text[i];
				END;
				path[k] := 0X;
				Console.WriteString("path=");	Console.WriteString(path);	Console.WriteLn;
			END;
		ELSE
			i := j; (* There were no path or switches *)
			ch := CmdLine.text[i];
		END;
		(* look for  filename *)
		WHILE (ch <= " ") & (ch # 0X) DO
			INC(i);	ch := CmdLine.text[i]; (* Skip blanks in front of filename *)
		END;
		k := 0;
		WHILE (ch > " ") & (k < LEN(name) - 1) DO
			name[k] := ch;	INC(k);
			INC(i);	ch := CmdLine.text[i];
		END;
		name[k] := 0X;
		IF k = 0 THEN
			Console.WriteString(NoFile);	Console.WriteLn;
			Console.WriteString(SlashQuestionForHelp);	Console.WriteLn;
			RETURN FALSE;
		END;
		Console.WriteString("file=");Console.WriteString(name);	Console.WriteLn;
		(* look for options *)
		WHILE (ch <= " ") & (ch # 0X) DO
			INC(i);	ch := CmdLine.text[i]; (* Skip blanks in front of options *)
		END;
		IF ch = 0X THEN (* There were no options *)
			RETURN TRUE;
		ELSIF ch # "@" THEN
			Console.WriteString(InvalidOptions);	Console.WriteLn;
			Console.WriteString(SlashQuestionForHelp);	Console.WriteLn;
			RETURN FALSE;
		ELSIF ch = "@" THEN
			INC(i);
			ch := CmdLine.text[i];
			IF ch <= " " THEN
				Console.WriteString(NoOptions);	Console.WriteLn;
				Console.WriteString(SlashQuestionForHelp);	Console.WriteLn;
				RETURN FALSE;
			END;
			k := 0;
			WHILE (ch > " ") & (k < LEN(opts) - 1) DO
				opts[k] := ch;	INC(k);
				INC(i);	ch := CmdLine.text[i];
			END;
			opts[k] := 0X;
			Console.WriteString("opts=");	Console.WriteString(opts);	Console.WriteLn;
			RETURN TRUE;
		END;
	END GetOptions;

	(***********************************)
	PROCEDURE Cap(ch: CHAR): CHAR;
		(* Standard CAP ruins non-latin characters, and I need them intact. *)
	BEGIN
		CASE ch OF
		| 'a'..'z':
			RETURN CAP(ch)
		ELSE
			RETURN ch
		END;
	END Cap;

	(***********************************)
	PROCEDURE CheckOptions(opts: ARRAY OF CHAR): BOOLEAN;
		VAR i: LONGINT;
	BEGIN
		i := 0;
		WHILE opts[i] # 0X DO
			CASE Cap(opts[i]) OF
			| 'A', 'E', 'F', 'N', 'P', 'S', 'T', 'V', 'W', 'X', 'Z', '1', '2', '3':
				INC(i);
			ELSE
				Console.Write(opts[i]);
				Console.WriteString(" - wrong option");	Console.WriteLn;
				Console.WriteString("Run 'O2ETHCLC /*' for help");	Console.WriteLn;
				RETURN FALSE;
			END;
		END;
		RETURN TRUE;
	END CheckOptions;

	(***********************************)
	PROCEDURE ParseOptions(VAR options: ARRAY OF CHAR; VAR opt: SET);
		VAR i: LONGINT;
	BEGIN
		opt := OPM.DefOpt;
		i := 0;
		LOOP
			CASE options[i] OF
			| 0X: EXIT
			| "f": INCL(opt, OPM.nofiles)
			| "F": EXCL(opt, OPM.nofiles)
			| "n": EXCL(opt, OPM.newsf)
			| "N": INCL(opt, OPM.newsf)
			| "e": EXCL(opt, OPM.extsf)
			| "E": INCL(opt, OPM.extsf)
			| "s": INCL(opt, OPM.systemchk)
			| "S": EXCL(opt, OPM.systemchk)
			| "w": EXCL(opt, OPM.warning)
			| "W": INCL(opt, OPM.warning)
			| "p": EXCL(opt, OPM.ptrinit)
			| "P": INCL(opt, OPM.ptrinit)
			| "z": EXCL(opt, OPM.fullstackinit)
			| "Z": IF OPM.ptrinit IN opt THEN INCL(opt, OPM.fullstackinit) END
			| "a": EXCL(opt, OPM.assert)
			| "A": INCL(opt, OPM.assert)
			| "x": EXCL(opt, OPM.inxchk)
			| "X": INCL(opt, OPM.inxchk)
			| "t": EXCL(opt, OPM.typchk)
			| "T": INCL(opt, OPM.typchk)
			| "v": EXCL(opt, OPM.ovflchk)
			| "V": INCL(opt, OPM.ovflchk)
			| "3": EXCL(opt, OPM.oberon2);	EXCL(opt, OPM.oberon1)
			| "2": INCL(opt, OPM.oberon2);	EXCL(opt, OPM.oberon1)
			| "1": INCL(opt, OPM.oberon1);	EXCL(opt, OPM.oberon2)
			END;
			INC(i);
		END;
	END ParseOptions;

	(***********************************)
	PROCEDURE Compile;
		VAR opts: ARRAY 32 OF CHAR;
			name, path: FileDir.FileName;
			error: BOOLEAN;
	BEGIN
		IF GetOptions(path, name, opts) THEN
			IF CheckOptions(opts) THEN
				error := FALSE;
				CompileFile(path, name, opts, error);
			END;
		END;
	END Compile;

	(***********************************)
	PROCEDURE SignOn;
	BEGIN
		Texts.WriteString(W, "Oberon Portable Compiler / nw, rc, nm, tk, prk");	Texts.WriteLn(W);
		Texts.WriteString(W, OPP.SignOnMessage);	Texts.WriteLn(W);
		Texts.Append(Texts.Log, W.buf)
	END SignOn;

	(***********************************)
	PROCEDURE CompileFile(path, name, opt: ARRAY OF CHAR; VAR error: BOOLEAN);
		VAR t: Texts.Text; r: Texts.Reader; pc: LONGINT;
	BEGIN
		SignOn;
		NEW(t);	Texts.Open(t, name);
		IF t.len # 0 THEN
			Texts.OpenReader(r, t, 0);
			Texts.WriteString(W, name);
			OPS.Init;
			Module(r, path, opt, pc, Texts.Log, error)
		ELSE
			Texts.WriteString(W, name);	Texts.WriteString(W, " not found");
			Texts.WriteLn(W); Texts.Append(Texts.Log, W.buf);
			error := TRUE;
		END
	END CompileFile;

	(***********************************)
	PROCEDURE Module(source: Texts.Reader; path, options: ARRAY OF CHAR; breakpc: LONGINT;
			log: Texts.Text; VAR error: BOOLEAN);
		VAR opt: SET; extSF, newSF: BOOLEAN; p: OPT.Node; modName: OPS.Name;
	BEGIN
		OPM.outputPrefix[0] := 0X;
		COPY(path, OPM.outputPath);
		COPY(Modules.extension, OPM.extension);
		ParseOptions(options, opt);
		WriteMsg(source, log);
		OPM.Init(opt, source, log);	OPS.ch := " ";
		OPB.typSize := OPV.TypSize;	OPV.Init(opt, breakpc);
		newSF := OPM.newsf IN opt;	extSF := OPM.extsf IN opt;
		OPP.Module(p, modName);
		IF OPM.noerr THEN
			OPL.Init;
			OPM.errpos := 0;
			OPM.Begin(modName);
			IF OPM.noerr THEN
				OPT.Export(modName, newSF, extSF);
				OPV.AdrAndSize(OPT.topScope);
				IF newSF THEN OPM.LogWStr(" new symbol file")
				ELSIF extSF THEN OPM.LogWStr(" extended symbol file")
				END;
				IF OPM.noerr THEN
					OPM.errpos := 0;
					OPC.Init;
					OPV.Module(p);
					IF OPM.noerr THEN
						OPL.OutCode(modName);
						IF OPM.noerr THEN
							OPM.LogWStr ("  code=");	OPM.LogWNum(OPO.pc, 1);
							OPM.LogWStr ("; data=");	OPM.LogWNum(OPO.dsize, 1);
						END
					END
				END;
				OPL.Close
			END
		END;
		OPT.CloseScope;	OPT.Close;
		OPM.LogWLn;	error := ~OPM.noerr;
		OPM.outputPath := "!";	OPM.outputPrefix := "!"	(* invalid filename *)
	END Module;

	(***********************************)
	PROCEDURE WriteMsg(source: Texts.Reader; log: Texts.Text);
		VAR sym: SHORTINT;
	BEGIN
		Texts.WriteString(W, " compiling ");
		OPM.Init({}, source, log);	OPS.Get(sym);
		IF sym = module THEN
			OPS.Get(sym);
			IF sym = ident THEN
				Texts.WriteString(W, OPM.outputPath);
				Texts.WriteString(W, OPM.outputPrefix);
				OPS.Get(sym);	Texts.WriteString(W, OPS.name);
				WHILE sym = period DO
					Texts.Write(W, ".");
					OPS.Get(sym);
					IF sym = ident THEN Texts.WriteString(W, OPS.name);	OPS.Get(sym) END;
				END;
				IF OPM.extension # Modules.extension THEN
					Texts.WriteString(W, OPM.extension)
				ELSIF (OPM.outputPath = "") & (OPM.outputPrefix = "") THEN	(* not cross-compiling *)
					IF Modules.FindMod(OPS.name) # NIL THEN
						Texts.WriteString(W, " (in use) ")
					END
				ELSE
					(* skip *)
				END
			END
		END;
		Texts.Append(log, W.buf)
	END WriteMsg;

(***********************************)
BEGIN
	Compile;
END O2ETHCLC.

PELinker.Link O2ETHCLC.Link~
