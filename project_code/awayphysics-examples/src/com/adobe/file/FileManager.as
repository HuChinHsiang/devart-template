/* AS3
	Copyright 2008 findsubstance;
*/
package src.file
{
	
	/**
	 *	FileManager;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 *
	 *	@author shaun.tinney@findsubstance.com;
	 *	@since  02.28.2008;
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import src.events.*;
	
	public class FileManager extends Sprite 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const ON_PROGRESS : String = 'onProgress';
		public static const ON_UPLOAD_ERROR : String = 'onUploadError';
		public static const ON_IMAGE_UPLOADED : String = 'onImageUploaded';
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function FileManager ( inUploadPHP : String, inUploadPath : String ) 
		{
			super();
			
			m_uploadURL = new URLRequest( inUploadPHP + '?path=' + inUploadPath );

			m_file = new FileReference();
			m_download = new FileReference();
            
			configureListeners( m_file, uploadSelectHandler );
			
			// simple listener for download complete;
			m_download.addEventListener( Event.SELECT, downloadCompleteHandler );
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------
		
		// display items;

		// vars;
		private var m_fileName : String;
		private var m_uploadURL : URLRequest;
		private var m_downloadURL : URLRequest;
		private var m_download : FileReference;
        private var m_file : FileReference;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public function browse () : void
		{
			m_file.browse( getImageTypes() );
		}
		
		public function download ( inURL : String, inName : String ) : void
		{
			m_downloadURL = new URLRequest( inURL )
			m_fileName = inName;
			
			m_download.download( m_downloadURL, m_fileName );
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		/**
		*	handlers for file upload ( complete set );	
		**/
		
		private function uploadSelectHandler ( e : Event ) : void 
		{
            var file : FileReference = FileReference( e.target );
			
			m_fileName = file.name;
            
			file.upload( m_uploadURL );
        }
		
		private function progressHandler ( e : ProgressEvent ) : void 
		{
            var file : FileReference = FileReference( e.target );

			dispatchEvent( new CustomEvent( ON_PROGRESS, { percent : normalize( e.bytesLoaded / e.bytesTotal ) } ) );
        }
		
        private function uploadCompleteDataHandler ( e : DataEvent ) : void 
		{
			dispatchEvent( new CustomEvent( ON_IMAGE_UPLOADED, { fileName : m_fileName } ) );
        }
        
        private function ioErrorHandler ( e : IOErrorEvent ) : void 
		{
			dispatchError( e );
        }       

		private function securityErrorHandler ( e : SecurityErrorEvent) : void 
		{			
			dispatchError( e );
        }

		private function openHandler ( e : Event ) : void {};
		
		private function cancelHandler ( e : Event ) : void {};

        private function completeHandler ( e : Event ) : void {};

		private function httpStatusHandler ( e : HTTPStatusEvent ) : void {};
		
		/**
		*	handler for file download;
		**/
		private function downloadCompleteHandler ( e : Event ) : void
		{
			trace( 'file download complete;' );
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
	
		private function dispatchError ( e : * ) : void
		{
			trace( 'ERROR: ' + e );
		}	
		
		private function configureListeners ( inDispatcher : IEventDispatcher, inSelectHandler : Function ) : void 
		{
            inDispatcher.addEventListener( Event.CANCEL, cancelHandler );
            inDispatcher.addEventListener( Event.COMPLETE, completeHandler );
            inDispatcher.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
            inDispatcher.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
            inDispatcher.addEventListener( Event.OPEN, openHandler );
            inDispatcher.addEventListener( ProgressEvent.PROGRESS, progressHandler );
            inDispatcher.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
            inDispatcher.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler );
			inDispatcher.addEventListener( Event.SELECT, inSelectHandler );
        }

		private function getImageTypes () : Array
		{
			return new Array( new FileFilter( "Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png" ) );
		}

		private function normalize ( inValue : Number ) : Number
		{
			var v : Number = inValue;
			
			if ( v > 1 ) v = 1;
			if ( v < 0 ) v = 0;
			
			v = Number( v.toFixed( 3 ) );
			
			return v;
		}
	}
}