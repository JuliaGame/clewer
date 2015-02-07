INSIDE = (0,0)
OUTSIDE = (9999, 9999)

function distSq(cell)
    return cell[1] ^ 2 + cell[2] ^ 2
end

function getCell(grid, x, y)
    return if x < 1 || x > size(grid, 2) || y < 1 || y > size(grid, 1)
        OUTSIDE
    else
        grid[y,x]
    end
end

function compare(grid, cell, x, y, ox, oy)
    other = getCell(grid, x + ox, y + oy)
    other = (other[1] + ox, other[2] + oy)
    return if distSq(other) < distSq(cell) other else cell end
end

function propagate(grid)
    height = size(grid, 1)
    width = size(grid, 2)
    for y in 1:height
        for x in 1:width
            cell = grid[y,x]
            cell = compare(grid, cell, x, y, -1,  0)
            cell = compare(grid, cell, x, y,  0, -1)
            cell = compare(grid, cell, x, y, -1, -1)
            cell = compare(grid, cell, x, y,  1, -1)
            grid[y,x] = cell
        end
        for x in width:-1:1
            cell = grid[y,x]
            cell = compare(grid, cell, x, y, 1, 0)
            grid[y,x] = cell
        end
    end
    for y in height:-1:1
        for x in width:-1:1
            cell = grid[y,x]
            cell = compare(grid, cell, x, y,  1, 0)
            cell = compare(grid, cell, x, y,  0, 1)
            cell = compare(grid, cell, x, y, -1, 1)
            cell = compare(grid, cell, x, y,  1, 1)
            grid[y,x] = cell
        end
        for x in 1:width
            cell = grid[y,x]
            cell = compare(grid, cell, x, y, -1, 0)
            grid[y,x] = cell
        end
    end
end
