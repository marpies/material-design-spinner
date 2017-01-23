/**
 * Copyright 2017 Marcel Piestansky (http://marpies.com)
 * Based on work by Jakub Wagner (https://twitter.com/@jakubwagner)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package feathers.extensions {

    import feathers.core.FeathersControl;

    import starling.animation.Juggler;
    import starling.animation.Transitions;
    import starling.core.Starling;
    import starling.display.Canvas;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.geom.Polygon;
    import starling.textures.Texture;

    public class MaterialDesignSpinner extends FeathersControl {

        [Embed(source="/../assets/material-design-spinner.png")]
        protected static var SPINNER_BITMAP:Class;

        protected static const INVALIDATION_FLAG_COLOR:String = "color";

        protected static const POLYGON_SIDES:int = 4; // Minimum 3
        protected static const ANIMATION_SPEED:Number = 1.8; // In seconds
        protected static const MIN_VALUE:Number = (Math.PI * 0.2) / (Math.PI * 2);
        protected static const MAX_VALUE:Number = (Math.PI * 1.55) / (Math.PI * 2);
        protected static var sTexture:Texture;

        protected var mProgress:Image;
        protected var mCanvas:Canvas;
        protected var mContainer:Sprite;
        protected var mPolygon:Polygon;

        protected var mColor:uint;
        protected var mValue:Number = 0;
        protected var mRadius:Number = 0;
        protected var mJuggler:Juggler;

        protected var mRunning:Boolean;
        protected var mProgressTweenProps:Object;
        protected var mCanvasTweenProps:Object;

        public function MaterialDesignSpinner() {
            super();

            mColor = 0xFFFFFF;
            mValue = MIN_VALUE;
            mJuggler = Starling.juggler;
            mProgressTweenProps = {};
            mCanvasTweenProps = {};

            if( sTexture == null ) {
                sTexture = Texture.fromBitmap( new SPINNER_BITMAP, false, false, 3 );
            }
        }

        override public function dispose():void {
            stopAnimation();

            mProgress = null;
            mCanvas = null;
            mContainer = null;
            mPolygon = null;
            mJuggler = null;

            mProgressTweenProps = null;
            mCanvasTweenProps = null;

            super.dispose();
        }

        /**
         *
         * Protected API
         *
         */

        override protected function initialize():void {
            super.initialize();

            mRadius = sTexture.width * 0.5;

            mContainer = new Sprite();
            mContainer.x = mContainer.y = mRadius;
            mContainer.pivotX = mContainer.pivotY = mRadius;
            addChild( mContainer );

            mProgress = new Image( sTexture );
            mContainer.addChild( mProgress );

            mCanvas = new Canvas();
            mCanvas.x = mCanvas.y = mRadius;
            mCanvas.pivotX = mCanvas.pivotY = mRadius;
            mContainer.addChild( mCanvas );

            mPolygon = new Polygon();
            mProgress.mask = mCanvas;

            width = mRadius * 2;
            height = mRadius * 2;
        }

        override protected function draw():void {
            super.draw();

            if( isInvalid( INVALIDATION_FLAG_COLOR ) ) {
                mProgress.color = mColor;
            }

            if( isInvalid( INVALIDATION_FLAG_DATA ) ) {
                drawPolygon();
            }
        }

        override protected function feathersControl_addedToStageHandler( event:Event ):void {
            super.feathersControl_addedToStageHandler( event );

            mRunning = true;

            animateProgress();
            addRotationAnimation();
        }

        override protected function feathersControl_removedFromStageHandler( event:Event ):void {
            super.feathersControl_removedFromStageHandler( event );

            mRunning = false;

            if( mCanvas != null ) {
                reset();
            }
        }

        /**
         *
         * Private API
         *
         */

        private function drawPolygon():void {
            updatePolygon( value, mRadius, mRadius, mRadius, Math.PI / 2 );

            mCanvas.clear();
            mCanvas.beginFill( 0xFF0000 );
            mCanvas.drawPolygon( mPolygon );
            mCanvas.endFill();
        }

        private function animateProgress():void {
            var newValue:Number = value > MIN_VALUE ? MIN_VALUE : MAX_VALUE;
            mProgressTweenProps.value = newValue;
            mProgressTweenProps.transition = Transitions.EASE_IN_OUT;
            mProgressTweenProps.onComplete = animateProgress;
            mJuggler.tween( this, ANIMATION_SPEED, mProgressTweenProps );

            mCanvasTweenProps.rotation = mCanvas.rotation + (newValue == MIN_VALUE ? Math.PI * 2 : Math.PI);
            mCanvasTweenProps.transition = Transitions.EASE_IN_OUT;
            mJuggler.tween( mCanvas, ANIMATION_SPEED, mCanvasTweenProps );
        }

        private function lineToRadians( radians:Number, radius:Number, x:Number, y:Number ):void {
            mPolygon.addVertices( Math.cos( radians ) * radius + x, Math.sin( radians ) * radius + y );
        }

        private function updatePolygon( percentage:Number, radius:Number = 50, x:Number = 0, y:Number = 0, rotation:Number = 0 ):void {
            mPolygon.numVertices = 0;
            mPolygon.addVertices( x, y );

            radius /= Math.cos( 1 / POLYGON_SIDES * Math.PI );

            var sidesToDraw:int = int( percentage * POLYGON_SIDES );
            for( var i:int = 0; i <= sidesToDraw; i++ ) {
                lineToRadians( (i / POLYGON_SIDES) * (Math.PI * 2) + rotation, radius, x, y );
            }

            if( percentage * POLYGON_SIDES != sidesToDraw ) {
                lineToRadians( percentage * (Math.PI * 2) + rotation, radius, x, y );
            }
        }

        private function stopAnimation():void {
            if( isInitialized ) {
                mJuggler.removeTweens( mContainer );
                mJuggler.removeTweens( mCanvas );
                mJuggler.removeTweens( this );
            }
        }

        private function reset():void {
            stopAnimation();
            value = MIN_VALUE;

            drawPolygon();

            mCanvas.rotation = 0;
            mContainer.rotation = 0;
        }

        private function addRotationAnimation():void {
            mJuggler.tween( mContainer, ANIMATION_SPEED, {rotation: Math.PI * 2, repeatCount: 0} );
        }

        /**
         *
         * Getters / Setters
         *
         */

        /**
         * @private
         */
        public function get value():Number {
            return mValue;
        }

        /**
         * @private
         */
        public function set value( value:Number ):void {
            if( mValue == value ) return;

            mValue = value;
            invalidate( INVALIDATION_FLAG_DATA );
        }

        public function get color():uint {
            return mColor;
        }

        public function set color( value:uint ):void {
            mColor = value;

            if( isInitialized ) {
                mProgress.color = mColor;
            }
        }

        public function get juggler():Juggler {
            return mJuggler;
        }

        public function set juggler( value:Juggler ):void {
            if( mJuggler == value ) return;

            stopAnimation();

            if( value === null ) {
                value = Starling.juggler;
            }
            mJuggler = value;

            if( mRunning ) {
                reset();

                animateProgress();
                addRotationAnimation();
            }
        }

    }

}