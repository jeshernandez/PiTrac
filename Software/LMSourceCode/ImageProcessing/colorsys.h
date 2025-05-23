/* SPDX-License-Identifier: GPL-2.0-only */

/* Copyright 2005-2011 Mark Dufour and contributors; License Expat (See LICENSE) */
/* Copyright (C) 2022-2025, Verdant Consultants, LLC. */


#pragma once

#include <opencv2/core/matx.hpp>

#include "gs_globals.h"


namespace golf_sim {

    struct colorsys
    {
    public:
        static GsColorTriplet rgbToYiq(const GsColorTriplet& rgb);
        static GsColorTriplet yiqToRgb(const GsColorTriplet& yiq);
        static GsColorTriplet rgb_to_hls(const GsColorTriplet& rgb);
        static GsColorTriplet hls_to_rgb(const GsColorTriplet& hls);
        static GsColorTriplet rgb_to_hsv(const GsColorTriplet& rgb);
        static GsColorTriplet hsv_to_rgb(const GsColorTriplet& hsv);

    private:
        const static float kOneThird;
        const static float kOneSixth;
        const static float kTwoThird;

        static float _v(float m1, float m2, float hue);

        inline static float fmods(float a, float b)
        {
            float f = fmod(a, b);
            if ((f < 0 && b>0) || (f > 0 && b < 0)) f += b;
            return f;
        }
    };

}
