function cell2csv(filename, cellArray)
    fid = fopen(filename, 'w');
    [rows, cols] = size(cellArray);
    for r = 1:rows
        for c = 1:cols
            val = cellArray{r, c};
            if isnumeric(val)
                fprintf(fid, '%g', val);
            else
                fprintf(fid, '%s', val);
            end
            if c ~= cols
                fprintf(fid, ',');
            end
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end
