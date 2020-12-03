#include "game.h"
#include "fragmessage_type.h"

namespace game {
    VARP(hudfragmessages, 0, 1, 1);
    VARP(hudfragmessageduration, 0, 1000, 10000);
    FVARP(hudfragmessagey, 0, 0.25f, 1.0f);
    FVARP(hudfragmessagescale, 0.1f, 0.5f, 1.0f);

    void drawfragmessages(fpsent *d, int w, int h)
    {
        if(d->fragmessages->empty()) return;

        float stepsize = (3*HICON_SIZE)/2;
        float stepdir = hudfragmessagey>0.5 ? 1 : -1;
        vec2 origin = vec2(.5f, hudfragmessagey).mul(vec2(w, h).div(hudfragmessagescale));

        pushhudmatrix();
        hudmatrix.scale(hudfragmessagescale, hudfragmessagescale, 1);
        flushhudmatrix();

        for(int i = d->fragmessages->length()-1; i>=0; i--)
        {
            fragmessage &m = (*d->fragmessages)[i];

            if(lastmillis-m.millis > hudfragmessageduration)
            {
                // all messages before i are older, so remove all of them
                d->fragmessages->remove(0, i+1);
                break;
            }

            int fademillis = 255; //todo: make fademillis = hudfragmessageduration/10;
            int alpha = 255;
            if(lastmillis-m.millis > hudfragmessageduration-fademillis) alpha -= lastmillis - m.millis - hudfragmessageduration + fademillis;

            vec2 drawposcenter = vec2(0, (d->fragmessages->length()-1-i)*stepdir*stepsize).add(origin);

            int tw, th; text_bounds(m.attackername, tw, th);
            vec2 drawpos = vec2(-2*(tw+HICON_SIZE), -th).div(2).add(drawposcenter);
            draw_text(m.attackername, drawpos.x, drawpos.y, 0xFF, 0xFF, 0xFF, alpha);

            drawpos = vec2(drawposcenter).sub(HICON_SIZE / 2);
            gle::color(bvec(0xFF, 0xFF, 0xFF), alpha);
            drawicon(HICON_FIST + m.weapon, drawpos.x, drawpos.y);

            text_bounds(m.victimname, tw, th);
            drawpos = vec2(2*HICON_SIZE, -th).div(2).add(drawposcenter);
            draw_text(m.victimname, drawpos.x, drawpos.y, 0xFF, 0xFF, 0xFF, alpha);
        }

        pophudmatrix();
    }
}