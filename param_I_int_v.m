function a_pf = ...
      param_I_v(param_vals, a_param_act, a_param_inact, id, props)
  
% param_I_v - An (non)inactivating current integrated over a changing V.
%
% Usage:
%   a_pf = 
%     param_I_v(param_vals, a_param_act, a_param_inact, dt, id, props)
%
% Parameters:
%   param_vals: Values for p, q, gmax [uS] and E [mV].
%   a_param_act, a_param_inact: param_act objects for m and h, resp.,
%   	obtained using the param_act_int_v function.
%   id: An identifying string for this function.
%   props: A structure with any optional properties.
% 	   (Rest passed to param_func)
%		
% Returns a structure object with the following fields:
%	a_pf: Holds the voltage->current function.
%
% Description:
%   Defines a function f(a_pf, struct('v', V [mV], 'dt', dt [ms])) where v is an array of voltage
% values [mV] changing with dt time steps [ms]. Initial values for the
% activation and inactivation variables are calculated from the first voltage
% value.
%
% Example:
% >> m_ClCa = param_act_int_v(f_IClCa_minf_v, f_IClCa_tau_v, 'm');
% >> f_IClCa_v = param_I_v([1 0 1 -41.7], m_ClCa, param_func_nil, 'I_ClCa');
%
% See also: param_act_int_v, param_func, tests_db, plot_abstract
%
% $Id: param_I_v.m 128 2010-06-07 21:36:08Z cengiz $
%
% Author: Cengiz Gunay <cgunay@emory.edu>, 2010/01/17

  if ~ exist('props', 'var')
    props = struct;
  end

  props = mergeStructs(props, ...
                       struct('paramRanges', ...
                              [0 4; 0 4; 0 1e3; -100 100]'));
  
  a_pf = ...
    param_mult(...
      {'time [ms]', 'current [nA]'}, ...
      [param_vals], {'p', 'q', 'gmax', 'E'}, ...
      struct('m', a_param_act, 'h', a_param_inact), ...
      @I_int, id, props);
  
  function I = I_int (fs, p, x)
    s = getFieldDefault(x, 's', []);
    v = x.v;
    dt = x.dt;
    if isempty(s)
      s = solver_int({}, dt, [ 'solver for ' id ] );
      s = initSolver(a_pf, s);
      var_int = integrate(s, v);
    end
    I = p.gmax * ...
      getVal(s, 'm') .^ p.p .* ...
      getVal(s, 'h') .^ p.q .* ...
      (v - p.E);
end

end
