function state = present_image(program, conf)

state = ptb.State();
state.Name = 'present_image';
state.Duration = conf.TIMINGS.time_in.present_image;
state.UserData = struct();

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% At the start of the state, mark that fixation to the image was not yet
% acquired; reset the fixation target, such that it has a cumuluative
% looking time of 0s; and draw the image associated with the target.
%
% Additionally, if we're in debug mode, draw the target bounds.

state.UserData.acquired_fixation = false;

image_obj = program.Value.stimuli.img1;
target_obj = program.Value.targets.img1;
reset( target_obj );

images = program.Value.images;
window = program.Value.window;

if ( ~isempty(images) )
  % Display a random image.
  image_n = randi( numel(images), 1 );
  image = images{image_n};
  
  image_obj.FaceColor = image;
  
  draw( image_obj, window );
end

if ( program.Value.is_debug )
  draw( target_obj.Bounds, window );
end

flip( window );

end

function loop(state, program)

target_obj = program.Value.targets.img1;

if ( target_obj.IsDurationMet )
  % Mark that we successfully acquired fixation.
  state.UserData.acquired_fixation = true;
  % Proceed to the exit() function.
  escape( state );
end

end

function exit(state, program)

states = program.Value.states;

if ( state.UserData.acquired_fixation )
  next( state, states('image_success') );
else
  next( state, states('image_error') );
end

end