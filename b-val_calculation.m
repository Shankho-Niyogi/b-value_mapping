clear
clc
close all

% SN April 3rd, 2022

% Parameters to change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mc = 4;
dx = 0.1; % grid increment for longitude
dy = 0.1; % grid increment for latitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts = detectImportOptions('eq_cat.xlsx', 'NumHeaderLines', 1);
eq_data = readtable('eq_cat.xlsx', opts);

lat_usgs = eq_data{:, 2};
lon_usgs = eq_data{:, 1};
eq_data_conv = eq_data{:, :};
[r, c] = size(eq_data_conv);

%%

arr_x = (floor(min(lon_usgs) - dx):dx:ceil(max(lon_usgs) + dx));
arr_y = (floor(min(lat_usgs) - dy):dy:ceil(max(lat_usgs) + dy));
l_x = length(arr_x);
l_y = length(arr_y);
grid_sum_mag = zeros(l_x, l_y);
grid_no_eqs = zeros(l_x, l_y);

%%

for k = 1:r
    i = find(arr_x <= eq_data_conv(k, 1), 1, 'last');
    j = find(arr_y <= eq_data_conv(k, 2), 1, 'last');
    
    if (~isempty(i) && ~isempty(j) && i < l_x && j < l_y)
        grid_sum_mag(i, j) = grid_sum_mag(i, j) + eq_data_conv(k, 6);
        grid_no_eqs(i, j) = grid_no_eqs(i, j) + 1;
    end
end

%%

b_val_grid = (log10(exp(1)) ./ ((grid_sum_mag ./ grid_no_eqs) - Mc));
b_val_grid(isnan(b_val_grid)) = 0;
b_val_grid(isinf(b_val_grid)) = 0;

%%

figure()
[X, Y] = meshgrid(arr_x, arr_y);
surf(X, Y, b_val_grid')
view(2)
ylabel('Latitude');
xlabel('Longitude')
ylim([arr_y(1) arr_y(end)]);
xlim([arr_x(1) arr_x(end)])
colorbar
title(sprintf('%0.2f X %0.2f degrees grid of earthquake b values', dx, dy))

figure()
histogram(lat_usgs)
title('Latitudinal earthquake distribution')
figure()
histogram(lon_usgs)
title('Longitudinal earthquake distribution')
