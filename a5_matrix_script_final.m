% Run matlab script a_matrix.m 
% Depending on switched off or on damping coefficent, run two script
% possibilities:
% 1. damping coefficent is switched off -> no exponential damping
% coefficient (e^0 = 1).
% 2. damping coefficent is switched on -> damping coefficient is computed
% based on damping ratio and undamped angular frequency (natural
% frequency).

% delete cache
clear all
clc
% close all

% Switch off the damping coefficient exponential factor in delta pricing
% equation:
% value 1 = "on", value 0 = "off"
h1_setGlobal_switch_on_damp_exp_coef(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set global variable initial parking pricing to 2.5:
h1_setGlobal_initial_parking_pricing(2.5);

% set global variable for maximum price increase per time step to 0.5:  
h1_setGlobal_max_parking_price_increase(0.5);

parking_pricing_switched_on = c13_input_switch_on_parking_pricing;

if parking_pricing_switched_on == 1
    
%   if damping coefficient exponential factor in delta pricing is switched
%   off or on:
    if h2_getGlobal_switch_on_damp_exp_coef == 0
        [matrix, parking_pricing, guessed_price_vector, E_p_vot, tau, penalty_distance] = a_matrix(0);
        
    elseif h2_getGlobal_switch_on_damp_exp_coef == 1   
       
%      Run script with no exponential damping coefficient (e^0 = 1)   
       [~, parking_pricing, ~, ~, ~, ~] = a_matrix(0);
        
%      Computation of damping coefficient: 
       interpol = interp1(linspace(1,size(parking_pricing,1),size(parking_pricing,1)),parking_pricing,linspace(1,size(parking_pricing,1),500));
       [Wn,zeta] = damp(interpol);
       damping_coefficient = mean(zeta) * mean(Wn);
       
       [matrix, parking_pricing, guessed_price_vector, E_p_vot, tau, penalty_distance] = a_matrix(damping_coefficient);
       damping_coefficient
    end    

% plot Queuing diagram:
c_outputs_plots(matrix)
% plot parking pricing:
c_outputs_plot_parking_pricing(parking_pricing)

% parking_pricing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif parking_pricing_switched_on == 0
    [matrix, parking_pricing, guessed_price_vector, E_p_vot, tau, penalty_distance] = a_matrix(0);
    c_outputs_plots(matrix)
end    

save('load_a5_matrix_script_final')

