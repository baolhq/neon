local collider = {}

function collider.aabb(a, b)
    return a.pos.x < b.pos.x + b.w and
        b.pos.x < a.pos.x + a.w and
        a.pos.y < b.pos.y + b.h and
        b.pos.y < a.pos.y + a.h
end

return collider
