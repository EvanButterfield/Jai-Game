// Workspace: Target Program
//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1293.
//
cs.y - b.h;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1295.
//
b.h;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1298.
//
id := get_id("!scrollbary".data, 11);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1302.
//
base.x = b.x + b.w;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1303.
//
base.w = context.mu_ctx.style.scrollbar_size;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1308.
//
cnt.scroll.y += context.mu_ctx.mouse_delta.y * cs.y / base.h;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1312.
//
cnt.scroll.y = clamp(cnt.scroll.y, 0, maxscroll);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1317.
//
thumb.h = max(context.mu_ctx.style.thumb_size, base.h * b.h / cs.y);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1318.
//
thumb.y += cnt.scroll.y * (base.h - thumb.h) / maxscroll;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1325.
//
cnt.scroll.y = 0;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1293.
//
cs.x - b.w;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1295.
//
b.w;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1298.
//
id := get_id("!scrollbarx".data, 11);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1302.
//
base.y = b.y + b.h;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1303.
//
base.h = context.mu_ctx.style.scrollbar_size;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1308.
//
cnt.scroll.x += context.mu_ctx.mouse_delta.x * cs.x / base.w;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1312.
//
cnt.scroll.x = clamp(cnt.scroll.x, 0, maxscroll);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1317.
//
thumb.w = max(context.mu_ctx.style.thumb_size, base.w * b.w / cs.x);

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1318.
//
thumb.x += cnt.scroll.x * (base.w - thumb.w) / maxscroll;

//
// #insert text. Generated from C:/Users/Sarah/Documents/jai/modules/Microui/module.jai:1325.
//
cnt.scroll.x = 0;
