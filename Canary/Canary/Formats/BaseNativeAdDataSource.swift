//
//  BaseNativeAdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import MoPub_AdMob_Adapters
import MoPub_Flurry_Adapters
import UIKit

/**
 Base native ad data source to share ad rendering configurations
 */
class BaseNativeAdDataSource: NSObject {
    // MARK: - Native Ad Rendering Configurations
    
    /**
     MoPub static ad renderer settings
     */
    var mopubRendererSettings: MPStaticNativeAdRendererSettings {
        // MoPub static renderer
        let mopubSettings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings()
        mopubSettings.renderingViewClass = NativeAdView.self
        mopubSettings.viewSizeHandler = { (width) -> CGSize in
            return CGSize(width: width, height: 275)
        }
        
        return mopubSettings
    }
    
    /**
     MoPub video ad renderer settings
     */
    var mopubVideoRendererSettings: MOPUBNativeVideoAdRendererSettings {
        // MoPub video renderer
        let mopubVideoSettings: MOPUBNativeVideoAdRendererSettings = MOPUBNativeVideoAdRendererSettings()
        mopubVideoSettings.renderingViewClass = NativeAdView.self
        mopubVideoSettings.viewSizeHandler = { (width) -> CGSize in
            return CGSize(width: width, height: 275)
        }
        
        return mopubVideoSettings
    }
    
    /**
     Ad renderer configurations.
     */
    var rendererConfigurations: [MPNativeAdRendererConfiguration] {
        // Array of rendering configurations
        var configs: [MPNativeAdRendererConfiguration] = []
        configs.append(MPStaticNativeAdRenderer.rendererConfiguration(with: mopubRendererSettings))
        configs.append(MOPUBNativeVideoAdRenderer.rendererConfiguration(with: mopubVideoRendererSettings))
        
        // Add the renderers for mediated networks
        configs = configs + networkRenderers
        
        return configs
    }
    
    // MARK: - Network Renderers
    
    /**
     Renderers for mediated networks
     */
    internal var networkRenderers: [MPNativeAdRendererConfiguration] {
        var renderers: [MPNativeAdRendererConfiguration] = []
        
        // OPTIONAL: AdMob native renderer
        if let admobConfig = MPGoogleAdMobNativeRenderer.rendererConfiguration(with: mopubRendererSettings) {
            renderers.append(admobConfig)
        }
        
        // OPTIONAL: Flurry native video renderer
        if let flurryConfig = FlurryNativeVideoAdRenderer.rendererConfiguration(with: mopubVideoRendererSettings) {
            renderers.append(flurryConfig)
        }
        
        return renderers
    }
}
