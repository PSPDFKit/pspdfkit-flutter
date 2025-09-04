/*
 * Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuConfigurationData

/**
 * Global storage for annotation menu configuration that can be shared between
 * the deprecated PspdfkitPluginMethodCallHandler and the new PspdfkitApiImpl.
 * 
 * This ensures consistent annotation menu behavior across both old and new APIs.
 */
object GlobalAnnotationMenuConfiguration {
    
    @Volatile
    private var configuration: AnnotationMenuConfigurationData? = null
    
    /**
     * Sets the global annotation menu configuration.
     * 
     * @param config The annotation menu configuration to store
     */
    fun setConfiguration(config: AnnotationMenuConfigurationData?) {
        synchronized(this) {
            configuration = config
        }
    }
    
    /**
     * Gets the current global annotation menu configuration.
     * 
     * @return The current configuration, or null if none is set
     */
    fun getConfiguration(): AnnotationMenuConfigurationData? {
        return configuration
    }
    
    /**
     * Clears the global annotation menu configuration.
     */
    fun clearConfiguration() {
        synchronized(this) {
            configuration = null
        }
    }
    
    /**
     * Checks if a configuration is currently set.
     * 
     * @return true if a configuration is set, false otherwise
     */
    fun hasConfiguration(): Boolean {
        return configuration != null
    }
}