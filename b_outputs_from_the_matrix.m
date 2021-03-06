matrix = matrix; %input from a_matrix.m
a = size(matrix,1);

% we are looking for values below.
% 1. �Total searching time� and �total searching distance�.
% 2. �Total non-searching time by parkers�, and �Total non-searching distance by parkers�.
% 3. �Total non-searching time by through traffic�, and �Total non-searching distance by through traffic�.
% 4. �Total waiting time to enter the area�.
% 5. All average values of the values above.


% The colomns represent states:
% |  1  |  2 | 3 |        21     |      22            |
% | Nns | Ns | Np|  Nns_parkers  | Nns_throughtraffic | 

    
n_state_Nns = zeros(a-1,1);
n_state_Ns = zeros(a-1,1);
n_state_Np = zeros(a-1,1);
n_state_Nns_parkers = zeros(a-1,1);
n_state_Nns_throughtraffic = zeros(a-1,1);
v = zeros(a-1,1);

for i=1:a-1
    n_state_Nns(i,1)=matrix(i,1);
    n_state_Ns(i,1)=matrix(i,2);
    n_state_Np(i,1)=matrix(i,3);
    n_state_Nns_parkers(i,1)=matrix(i,21);
    n_state_Nns_throughtraffic(i,1)=matrix(i,22);
    v(i,1)=matrix(i,6);
    t=1/60;
    %NOTE HERE, THE VALUE OF t (TIME SLICE) MIGHT BE CHANGED, ACCORDING TO
%"a_matrix.m"
end

total_searching_time=0;
total_searching_distance=0;
total_non_searching_time_parkers=0;
total_non_searching_distance_parkers=0;
% total_non_searching_time_throughtraffic=0;
% total_non_searching_distance_throughtraffic=0;
% total_waiting_time=0;

total_number=matrix(a-1,13);
total_number_parkers= total_number*(1-c2_input_beta);
total_number_throughtraffic= total_number*(c2_input_beta);

 
for i=1:a-1
total_searching_time=total_searching_time+n_state_Ns(i,1)*t*60; % unit is minutes.
total_searching_distance= total_searching_distance + n_state_Ns(i,1)*v(i,1)*t;

% total_non_searching_time_parkers= total_non_searching_time_parkers+ n_state_Nns(i,1)*t*60; % unit is minutes.
total_non_searching_time_parkers= total_non_searching_time_parkers+ n_state_Nns_parkers(i,1)*t*60; % unit is minutes.
% total_non_searching_distance_parkers= total_non_searching_distance_parkers+ n_state_Nns(i,1)*v(i,1)*t;
total_non_searching_distance_parkers= total_non_searching_distance_parkers+ n_state_Nns_parkers(i,1)*v(i,1)*t;

% total_non_searching_time_throughtraffic= total_non_searching_time_throughtraffic+ n_state_Nns_throughtraffic(i,1)*t*60; % unit is minutes.
% total_non_searching_distance_throughtraffic= total_non_searching_distance_throughtraffic+ n_state_Nns_throughtraffic(i,1)*v(i,1)*t;

% total_non_searching_time = total_non_searching_time_parkers+ total_non_searching_time_throughtraffic;
% total_non_searching_distance = total_non_searching_distance_parkers+ total_non_searching_distance_throughtraffic;

% total_waiting_time= total_waiting_time+(matrix(i,13)-matrix(i,14))*t*60;% unit is minutes.
end
 

average_searching_time =total_searching_time /total_number_parkers; % unit is minutes.
average_searching_distance= total_searching_distance/ total_number_parkers;

average_non_searching_time_parkers= total_non_searching_time_parkers/ total_number_parkers; % unit is minutes.
average_non_searching_distance_parkers= total_non_searching_distance_parkers/total_number_parkers;

total_time = total_searching_time + total_non_searching_time_parkers;
average_total_time = total_time / total_number_parkers;

total_distance = total_searching_distance + total_non_searching_distance_parkers;
average_total_distance = total_distance / total_number_parkers;

% average_non_searching_time_throughtraffic= total_non_searching_time_throughtraffic/total_number_throughtraffic; % unit is minutes.
% average_non_searching_distance_throughtraffic= total_non_searching_distance_throughtraffic/ total_number_throughtraffic;

% average_non_searching_time = total_non_searching_time/total_number; % unit is minutes.
% average_non_searching_distance = total_non_searching_distance/total_number;

% average_waiting_time = total_waiting_time/total_number; % unit is minutes.

%------------------------------------------------------------------------------------------------

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total revenue from on-street parking:
% Idea: Number of vehicles n_s_p * on-street parking fee

revenue(:,1) = zeros(size(matrix(:,10),1) - 1,1);
cum_revenue(:,1) = zeros(size(matrix(:,10),1) - 1,1);
correct_parking_pricing(:,1) = zeros(size(matrix(:,10),1) - 1,1);

% Get the correct parking pricing value (update only every 5 minutes and
% rounded to next 0.5 CHF):
for j = 1:5:size(parking_pricing(:,1),1)
    
    correct_parking_pricing(j,1) = round(2*parking_pricing(j,1))/2;
    if j ~= size(parking_pricing(:,1),1)
        correct_parking_pricing(j + 1,1) = correct_parking_pricing(j,1);
        correct_parking_pricing(j + 2,1) = correct_parking_pricing(j,1);
        correct_parking_pricing(j + 3,1) = correct_parking_pricing(j,1);
        correct_parking_pricing(j + 4,1) = correct_parking_pricing(j,1);
    end
end
    
%  get revenue value from corrected parking pricing value for every 5 minutes:   
for i = 2:size(matrix(:,10),1)
    revenue(i-1,1) = matrix(i,10)*correct_parking_pricing(i-1,1);

    if i ~= 2
        cum_revenue(i-1,1) = cum_revenue(i-2,1) + revenue(i-1,1);
    elseif i == 2
        cum_revenue(i-1,1) = revenue(i-1,1);
    end
end
max_cum_revenue = max(cum_revenue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Total revenue from on-street parking (relates to regression approximation):
% % % Idea: Number of vehicles n_s_p * on-street parking fee
% % 
% % revenue_fit(:,1) = zeros(size(matrix(:,10),1) - 1,1);
% % cum_revenue_fit(:,1) = zeros(size(matrix(:,10),1) - 1,1);
% % correct_parking_pricing_fit(:,1) = zeros(size(matrix(:,10),1) - 1,1);
% % 
% % x_value = (1:5:size(parking_pricing,1))';
% % y_value = round(2*parking_pricing(1:5:size(parking_pricing,1)))/2;
% % coeffs = polyfit(x_value, y_value, 14);
% % xfit = linspace(x_value(1), max(x_value), size(x_value,1));
% % yfit = polyval(coeffs, xfit);
% % 
% % % Get the correct parking pricing value (update only every 5 minutes and
% % % rounded to next 0.5 CHF):
% % for j = 1:5:size(parking_pricing(:,1),1)
% %     
% %     correct_parking_pricing_fit(j,1) = round(2*yfit(1,(j-1)/5 + 1))/2;
% %     if j ~= size(parking_pricing(:,1),1)
% %         correct_parking_pricing_fit(j + 1,1) = correct_parking_pricing_fit(j,1);
% %         correct_parking_pricing_fit(j + 2,1) = correct_parking_pricing_fit(j,1);
% %         correct_parking_pricing_fit(j + 3,1) = correct_parking_pricing_fit(j,1);
% %         correct_parking_pricing_fit(j + 4,1) = correct_parking_pricing_fit(j,1);
% %     end
% % end
% %     
% % % Get revenue value from corrected parking pricing value for every 5 minutes:   
% % for i = 2:size(matrix(:,10),1)
% %     revenue_fit(i-1,1) = matrix(i,10)*correct_parking_pricing_fit(i-1,1);
% % 
% %     if i ~= 2
% %         cum_revenue_fit(i-1,1) = cum_revenue_fit(i-2,1) + revenue_fit(i-1,1);
% %     elseif i == 2
% %         cum_revenue_fit(i-1,1) = revenue_fit(i-1,1);
% %     end
% % end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Total revenue from on-street parking (Constant on-street parking fee):
% % Number of vehicles n_s_p * on-street parking fee:
% total_revenue_on_street_parking = sum(matrix(:,10)*c8_input_parking_price);

%------------------------------------------------------------------------------------------------

total_searching_time
total_non_searching_time_parkers

total_searching_distance
total_non_searching_distance_parkers

average_searching_time
average_non_searching_time_parkers

average_searching_distance
average_non_searching_distance_parkers

%------------------------------------------------------------------------------------------------

avg_total_time = round(average_total_time,3)
tot_time = round(total_time,3)
% tot_time_VOT = round(total_time * 0.425,3)

avg_total_distance = round(average_total_distance,3)
tot_distance = round(total_distance,3)

final_cum_revenue = round(max_cum_revenue,0)

%------------------------------------------------------------------------------------------------

% avg_total_time_percentage = avg_total_time/9.408 * 100
% tot_time_percentage = tot_time/19465.681 * 100
% tot_time_VOT_percentage = tot_time_VOT/8272.914 * 100
% 
% avg_total_distance_percentage = avg_total_distance/1.96 * 100
% tot_distance_percentage = tot_distance/4055.35 * 100
% 
% cum_revenue_percentage = round(final_cum_revenue/12712 * 100,1)
