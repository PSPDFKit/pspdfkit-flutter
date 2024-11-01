package com.pspdfkit.flutter.pspdfkit.pdfgeneration

import android.content.Context
import android.graphics.RectF
import android.net.Uri
import com.pspdfkit.document.processor.NewPage
import com.pspdfkit.document.processor.PageImage
import com.pspdfkit.document.processor.PagePattern
import com.pspdfkit.document.processor.PagePdf
import com.pspdfkit.document.processor.PagePosition
import com.pspdfkit.document.processor.PageZOrder
import com.pspdfkit.utils.Size

class PdfPageAdaptor(private val context: Context) {

    fun parsePages(pages: List<Map<String, Any>>): List<NewPage> {
        return pages.map {
            buildPage(it)
        }
    }

    private fun buildPage(pageConfigurations: Map<String, Any>): NewPage {
        val pageSize = resolvePageSize(pageConfigurations["pageSize"] as List<Float>);
        val page: NewPage.Builder = when (pageConfigurations["type"]) {
            "pattern" -> {
                val pattern =
                    resolvePagePattern(pageConfigurations["pattern"] as HashMap<String, Any>)
                NewPage.patternPage(
                    pageSize,
                    pattern
                )
            }
            "imagePage" -> {
                val pageImage = parseImage(pageConfigurations["imagePage"] as HashMap<String, Any>)
                NewPage.emptyPage(
                    pageSize,
                ).withPageItem(
                    pageImage
                )
            }
            "pdfPage" -> {
                val pdfPage = parsePdf(pageConfigurations["pdfPage"] as HashMap<String, Any>)
                NewPage.emptyPage(
                    pageSize,
                ).withPageItem(
                    pdfPage
                )
            }
            else -> {
                throw IllegalArgumentException("Invalid page type")
            }
        }

        if (pageConfigurations.containsKey("backgroundColor")) {
            val color = pageConfigurations["backgroundColor"] as Long;
            page.backgroundColor(color.toInt())
        }

        if (pageConfigurations.containsKey("rotation")) {
            var pageRotation = pageConfigurations["rotation"]

            if (pageRotation is Long) {
                pageRotation = pageRotation.toInt()
            } else if (pageRotation !is Int) {
                throw IllegalArgumentException("Invalid rotation")
            }
            page.rotation(pageRotation)
        }

        if (pageConfigurations.containsKey("margins")) {
            val margins = resolveMargins(pageConfigurations["margins"] as List<Float>)
            page.withMargins(margins)
        }
        return page.build()
    }

    private fun resolveMargins(floats: List<Float>): RectF {
        return RectF(floats[0], floats[1], floats[2], floats[3])
    }

    private fun parsePdf(pageConfig: HashMap<String, Any>): PagePdf {
        var pageIndex = pageConfig["pageIndex"]

        if (pageIndex is Long) {
            pageIndex = pageIndex.toInt()
        } else if (pageIndex !is Int) {
            throw IllegalArgumentException("Invalid page index")
        }

        val pdfPage = if (pageConfig.containsKey("position")) PagePdf(
            context,
            Uri.parse(pageConfig["documentUri"] as String),
            pageIndex,
            resolvePagePosition(pageConfig["position"] as String)
        ) else PagePdf(
            context,
            Uri.parse(pageConfig["documentUri"] as String),
            pageIndex,
        )
        return pdfPage.apply {
            if (pageConfig.containsKey("zOrder")) {
                zOrder = resolvePageZOrder(pageConfig["zOrder"] as String)
            }
        }
    }

    private fun parseImage(imageConfig: Map<String, Any>): PageImage {

        return PageImage(
            context, Uri.parse(imageConfig["imageUri"] as String),
            resolvePagePosition(imageConfig["position"] as String),
        ).apply {
            if (imageConfig.containsKey("quality")) {
                var quality = imageConfig["quality"]

                if (quality is Long) {
                    quality = quality.toInt()
                } else if (quality !is Int) {
                    throw IllegalArgumentException("Invalid quality")
                }

                setJpegQuality(quality)
            }
            if (imageConfig.containsKey("rotation")) {
                var pageRotation = imageConfig["rotation"]

                if (pageRotation is Long) {
                    pageRotation = pageRotation.toInt()
                } else if (pageRotation !is Int) {
                    throw IllegalArgumentException("Invalid rotation")
                }
                rotation = pageRotation
            }
        }
    }


    private fun resolvePagePattern(patternConfig: HashMap<String, Any>): PagePattern {

        val pattern = patternConfig["pattern"] as String?
        val patterDocument = patternConfig["patternDocument"] as String?

        if (patterDocument != null) {
            val patterUri = Uri.parse(patterDocument)
            return PagePattern(patterUri)
        } else if (pattern != null) {
            return when (pattern) {
                "BLANK" -> PagePattern.BLANK
                "LINES_5MM" -> PagePattern.LINES_5MM
                "LINES_7MM" -> PagePattern.LINES_5MM
                "DOTS_5MM" -> PagePattern.DOTS_5MM
                "GRID_5MM" -> PagePattern.GRID_5MM
                else -> throw IllegalArgumentException("Invalid page pattern")
            }
        }
        throw IllegalArgumentException("Invalid page pattern")
    }

    private fun resolvePagePosition(position: String): PagePosition {
        return when (position) {
            "TOP" -> PagePosition.TOP
            "BOTTOM" -> PagePosition.BOTTOM
            "LEFT" -> PagePosition.LEFT
            "RIGHT" -> PagePosition.RIGHT
            "CENTER" -> PagePosition.CENTER
            "TOP_LEFT" -> PagePosition.TOP_LEFT
            "TOP_RIGHT" -> PagePosition.TOP_RIGHT
            "BOTTOM_LEFT" -> PagePosition.BOTTOM_LEFT
            "BOTTOM_RIGHT" -> PagePosition.BOTTOM_RIGHT
            else -> throw IllegalArgumentException("Invalid page position")
        }
    }

    private fun resolvePageZOrder(order: String): PageZOrder {
        return when (order) {
            "FOREGROUND" -> PageZOrder.FOREGROUND
            "BACKGROUND" -> PageZOrder.BACKGROUND
            else -> throw IllegalArgumentException("Invalid page z-order")
        }
    }

    private fun resolvePageSize(pageSize: List<Float>): Size {
        return Size(pageSize[0], pageSize[1])
    }

}
