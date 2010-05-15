function movie (action, mmov="octave_movie.mp4")
  ## Create a movie from plots
  ##
  ## Example usage:
  ##   figure("visible","off"); movie("init")
  ##   a=zeros(100,100); a(1:20,41:60)=1;
  ##   for i=1:100; a=shift(a,1); imshow(a); movie("add"); endfor
  ##   movie("close"); close; system("totem octave_movie.mp4")
  ##
  ## There are three commands used as first argment: "init", "add",
  ## "close". By default, a movie named "octave_movie.mp4" is created
  ## using ffmpeg.  An optional second argument allows one changing both
  ## the name and the type of movie.  The type ".dir" creates a
  ## directory containing a png file per frame.  The type ".zip"
  ## archives it using zip.  Types ".mp4", ".ogg", ".mov", ".mjpeg",
  ## ".avi", ".flv" are created using ffmpeg; types ".mng", ".gif" are
  ## created using convert; type ".swf" is created using png2swf.  You
  ## must have the relevant program installed to create a movie with the
  ## corresponding extension; no program is required for ".dir".

  ## Francesco Potortì, 2008
  ## Revision 1.10
  ## License: GPL version 3 or later

  verbose = false;
  rate = 5;                        # frames per second

  actions = {"init" "add" "close"};
  # gif swf
  types = {".mp4" ".mng" ".gif" ".zip" ".ogg" ".swf" ".mov" ".mjpeg" ".avi" ".flv" ".dir"};
  if (nargin < 1 || !ischar(action) || !any(strcmp(action, actions)))
    error("first argument must be one of:%s", sprintf(" %s",actions{:}));
  endif
  if (nargin >= 2 && !ischar(mmov))
    error("second arg must be a string");
  endif
  [mpath mname mtype] = fileparts(mmov);

  mdir = fullfile(mpath, [mname ".d"]);

  ppat =  "%06d.png";
  mpat = fullfile(mdir, ppat);
  mglob = fullfile(mdir, strrep(sprintf(ppat,0),"0","[0-9]"));
  fnof = fullfile(mdir, "+frame-number+");

  switch (action)
    case actions{1}                # init a movie
      if (isdir(mmov))
        cleandir(mmov, verbose)
      else
        unlink(mmov);
      endif
      while (!([allgood msg] = mkdir(mdir)))
        if (stat(fnof) && load(fnof).frameno == 0)
          error("while creating dir '%s': %s", mdir, msg);
        else
          cleandir(mdir, verbose);
        endif
      endwhile
      frameno = 0; save("-text",fnof,"frameno");
      if (verbose) printf("Directory '%s' created.\n", mdir); endif
    case actions{2}                # add a frame
      load(fnof);
      mfile = sprintf(mpat, ++frameno);
      drawnow("png", mfile);
      save("-text",fnof,"frameno");
      if (verbose) printf("Frame '%s' added.\n", mfile); endif
    case actions{3}                # close the movie
      switch (mtype)
        case {types{[1 5 7 8 9 10]}} # mp4, ogg, mov, mjpeg, avi, flv
          cmd = sprintf("ffmpeg -y -r %d -sameq -i %s %s 2>&1", rate, mpat, mmov);
        case {types{[2 3]}}        # mng, gif
          cmd = sprintf("convert %s -adjoin %s 2>&1", mglob, mpat);
        case types{4}                # zip
          cmd = sprintf("zip -qr9 %s %s 2>&1", mmov, mglob);
        case types{6}                # swf
          cmd = sprintf("png2swf -z -r %d -o %s %s", rate, mmov, mglob);
        case types{end}                # dir
          rename(mdir, mmov); return
	otherwise
          error("second arg must end with one of:%s", sprintf("%s",types{:}));
      endswitch
      [status output] = system(cmd);
      if (status != 0)
        load(fnof);
        error("Creation of movie '%s' containing %d frames failed:\n%s", mmov, frameno, output);
      endif
      if (verbose) printf("Movie '%s' contains %d frames:\n%s", mmov, frameno, output); endif
      cleandir(mdir, verbose);
  endswitch
endfunction


function cleandir(mdir, verbose)
  unwind_protect
    save_crr = confirm_recursive_rmdir(false);
    [allgood msg] = rmdir(mdir,"s");
    if (!allgood)
      error("while removing dir '%s': %s", mdir, msg); endif
  unwind_protect_cleanup
    confirm_recursive_rmdir(save_crr);
  end_unwind_protect
  if (verbose) printf("Directory '%s' removed\n", mdir); endif
endfunction
