for n = 3:8189
    spath = "Training Images/" + labels(n);
    if (n < 10)
        lpath = "jpg/image_0000" + n + ".jpg";
    elseif (n < 100)
        lpath = "jpg/image_000" + n + ".jpg";
    elseif (n < 1000)
        lpath = "jpg/image_00" + n + ".jpg";
    else
        lpath = "jpg/image_0" + n + ".jpg";
    end
    movefile(char(lpath), char(spath))
end