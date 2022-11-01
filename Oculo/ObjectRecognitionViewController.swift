//
//  ObjectDetectionViewController.swift
//  Oculo
//
//  Created by Kim, Raymond on 2022/10/27.
//  Copyright © 2022 Intelligent ATLAS. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class ObjectRecognitionViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {

    // 프레임 버퍼 사이즈 정의 Frame buffer size declaration
    var bufferSize: CGSize = .zero

    // Variable for the root layer: CALayer
    var AIModelInferenceDisplayLayer: CALayer! = nil

//    @IBOutlet weak private var previewView: UIView!  // MARK: Storyboard component
    private var previewView: UIView!

    // MARK: Setup the live capture
    /// 캡쳐 세션을 위한 카메라 정의(설정)
    /// AVFoundation에서 카메라 아웃풋을 받아서 object detection 뷰 컨트롤러에 전달하는 구조
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput",
                                                     qos: .userInitiated,  // qos: quality of service? 인듯
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)

    /// captureOutput 메서드는 이후 서브클래스에서 구현함.
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
    }

    // MARK: 이 부분 잘 이해가 안 되는데 누가 좀 알려주세요
    /// 재작성될 수 있는 리소스를 삭제하는 함수 재정의
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!

        /// 장치 및 캡쳐 세션의 해상도 설정
        /// Test1: Ultra Wide Angle Camera
        let ultraWideAngleVideoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera],
                                                                         mediaType: .video,
                                                                         position: .back).devices.first

        /// Test2: Wide Angle Camera
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: availableDevices!)  /// Create an input
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        /// 카메라의 해상도를 모델에 사용된 이미지의 해상도보다 크거나 가장 가까운 해상도로 설정함.

        // MARK: beginConfiguration - commitConfiguration
        /**
         @method beginConfiguration
         beginConfiguration 메서드는 commitConfiguration 메서드와 함께 AVCaptureSession의 메커니즘으로, 두 메서드가 쌍을 이룸으로써 클라이언트가 세션을 실행할 때 여러 가지 설정 작업을 원자적으로 업데이트 방식으로 일괄 처리하도록 만든다.
         [session beginConfiguration]을 호출한 후 클라이언트는 output을 더하거나 제거할 수 있고, sessionPreset을 변경하거나 개별 AVCaptureInput 또는 Output 속성을 구성할 수 있다. 모든 변경 사항은 클라이언트가 [session commitConfiguration]을 호출할 때까지 보류되며, [session commitConfiguration]이 호출될 때 일괄 처리된다.
         beginConfiguration / commitConfiguration 메서드 쌍은 중첩시켜 사용할 수 있고, 가장 바깥 부분의 커밋이 호출될 때에만 적용된다.
         */
        captureSession.beginConfiguration()

        // MARK: sessionPreset
        /**
         @property sessionPreset
         sessionPreset 프로퍼티의 값은 수신자(receiver)에서 사용 중인 현재 세션의 사전 설정인 AVCaptureSessionPreset임.
         sessionPreset 속성은 수신자가 실행되는 중에 설정될 수 있음.
         */
        captureSession.sessionPreset = .vga640x480  /// 모델 이미지 사이즈를 너무 크게 하면 연산량이 많아지므로 해상도를 낮춰 설정

        // MARK: Add a video input
        /// 나머지 스케일링 프로세스는 Vision 프레임워크에서 처리
        guard captureSession.canAddInput(deviceInput) else {
            print("Cannot add the video device input to the session")

            // MARK: beginConfiguration - commitConfiguration
            /**
             @method commitConfiguration
             beginConfiguration 메서드와 함께 쌍을 이뤄 클라이언트가 세션을 실행할 때 여러 가지 설정 작업을 원지적 업데이트(atomic update) 방식으로 일괄(batch) 처리하는 데 사용함.
             */
            captureSession.commitConfiguration()
            return
        }

        /// 카메라를 장치(device)로서 추가하여 세션에 비디오 입력 추가
        captureSession.addInput(deviceInput)

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)

            /// 비디오 데이터 output 추가

            // MARK: alwaysDiscardsLateVideoFrames
            /**
             @property alwaysDiscardsLateVideoFrames
             alwaysDiscardsLateVideoFrames 프로퍼티는 수신자(receiver)가 다음 프레임이 캡처되기 전에 처리되지 않은 비디오 프레임을 항상 버리도록 할 것인지 여부를 지정함.

             alwaysDiscardsLateVideoFrames 속성값이 YES 로 설정돼 있는 경우 수신자(receiver)는 기준 프레임을 처리하는  디스패치 대기열이 captureOutput:didOutputSampleBuffer:fromConnection: 델리게이트 메서드에서 막혀(blocked) 있는 동안 캡처된 프레임을 즉시 버린다.

             NO 로 설정돼 있는 경우에는 새 프레임이 삭제되기 전, 이전 프레임을 처리하는 데 더 많은 시간이 허용되기는 하지만 메모리 사용량이 크게 증가할 가능성이 있다.

             기본값은 YES
             */
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            // MARK: Specify the pixel format; kCVPixelBufferPixelFormatTypeKey, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            /**
             kCVPixelBufferPixelFormatTypeKey: CFString --> A single CFNumber or a CFArray of CFNumbers (OSTypes)
             kCVPixelFormatType_420YpCbCr8BiPlanarFullRange: Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct\

             Y'CbCr: 디지털 형식의 YUV - Y(Luminance: 밝기), U(파란색), V(빨간색)  * 참고: 아날로그 형식일 때는 YUV를 Y'PbPr 로 표현함.
             출처:  https://aigong.tistory.com/198
             */

            // MARK: Y'CbCr 8-bit 4:2:0 --> Cb : Cr = 1 : 2 샘플링
            /**
             1. 8비트 full-range R'G'B --> Y'CbCr 변환식
                 Y' = 16 + ((65.481 * R'd) / 255) + ((128.553 * G'd) / 255) + ((24.966 * B'd) / 255)
                 Cb = 128 - ((37.797 * R'd) / 255) - ((74.203 * G'd) / 255) + ((112.0 * B'd) / 255)
                 Cr = 128 + ((112.0 * R'd) / 255) - ((93.786 * G'd) / 255) - ((18.214 * B'd) / 255)

             2. MARK: Y'CbCr --> R'G'B' 변환식
                 R'd = ((298.082 * Y') / 256) + ((408.583 * Cr)) - 222.921
                 G'd = ((298.082 * Y') / 256) - ((100.291 * Cb) / 256) - ((208.120 * Cr) / 256) + 135.576
                 B'd = ((298.082 * Y') / 256) + ((516.412 * Cb) / 256) - 276.836
             */
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            captureSession.commitConfiguration()
            return
        }

        /// 모든 프레임을 실행 가능하도록 설정

        // MARK: connection
        /**
         @method connectionWithMediaType:
         connectionWithMediaType 메서드는 지정된 mediaType의 AVCaptureInputPort가 있는 수신자(receiver)의 연결 배열(connections array)에서 첫 번째 연결(connection)인 AVCaptureConnection을 반환한다.
         지정된 mediaType과의 연결이 없으면 nil이 반환됨

         @param mediaType
         AVMediaFormat.h의 AVMediaType 상수
         예시: AVMediaTypeVideo.

         사용법: connection(with mediaType: AVMediaType) -> AVCaptureConnection?
         */
        let captureConnection = videoDataOutput.connection(with: .video)

        /// 프레임이 항상 실행되도록 설정
        /// Vision 프레임워크의 요청을 한 번에 두 개 이상 갖고 있지 않도록 할 것: 버퍼 대기열이 사용 가능한 메모리를 초과하면 카메라가 멈춰 버린다.
        captureConnection?.isEnabled = true
        do {
            // MARK: .lockForConfiguration()
            /**
             @method lockForConfiguration
             @abstract
             lockForConfiguration 메서드는 장치 하드웨어 속성을 구성하기 위해 독점적(혹은 전용의; exclusive) 액세스를 요청함
             이 메서드가 필요한 이유는 focusMode 및 ExposureMode와 같은 AVCaptureDevice에 하드웨어 속성을 설정하려면 클라이언트가 먼저 장치에 대한 잠금 권한을 획득해야 하기 때문임.
             클라이언트는 설정 가능한 장치 속성이 변경되지 않은 상태로 유지되어야 하는 경우에만 장치의 잠금 상태를 유지해야 함
             그럴 필요가 없는 상황에서 장치 잠금 상태를 유지하는 경우 장치를 공유하는 다른 응용 프로그램에서 캡처 품질이 저하될 수 있음

             @param outError. * 이건 실제로 찍어보지 않아서 애매할 수 있음
             리턴하는 시점에서 장치를 잠글 수 없는 경우 오류 발생 원인을 설명하는 NSError를 포인팅함
             결과로 BOOL 값을 보여주는데, 이 boolean은 장치가 구성(configuration)되기 위해 잘 잠겼는지 여부를 나타내는 값이다.
             */
            try availableDevices!.lockForConfiguration()

            /// 버퍼 크기를 광각 카메라 이미지의 물리적 크기와 같게 설정

            // MARK: CMVideoFormatDescriptionGetDimensions
            /**
             @function    CMVideoFormatDescriptionGetDimensions
             @declaration
             func CMVideoFormatDescriptionGetDimensions(_ videoDesc: CMVideoFormatDescription) -> CMVideoDimensions

             인코딩된 픽셀로 차원(dimensions)을 반환함.. 근데 무슨 차원을 반환하는지 모르겠다!
             픽셀 종횡비 또는  깨끗한 조리개 태그(clean aperture tags)를 고려하지 않음  // MARK: 뭔소리여?
             */

            // MARK: activeFormat
            /**
             @property activeFormat
             현재 활성화된 수신자(receiver) 형식(format)을 나타내는 프로퍼티

             @discussion
             activeFormat 프로퍼티는 현재 활성 장치 형식을 가져오거나 설정하는 데 사용함.

             setActiveFormat:
             형식 배열에 없는 형식으로 설정된 경우 NSInvalidArgumentException 예외(exception)를 던짐(throw).
             lockForConfiguration 인스턴스 메서드를 사용하여 수신자(receiver)에 대한 독점적 접근 권한을 먼저 얻지 않은 상태에서 호출되면 NSGenericException 예외를 던짐.

             클라이언트는 activeFormat 프로퍼티를 관찰하는 키 값에 의해 수신자의 activeFormat에 대한 변경 내역을 자동으로 관찰할 수 있음.

             iOS에서 AVCaptureDevice의 setActiveFormat 및 AVCaptureSession의 setSessionPreset 사용은 상호 배타적임. 즉, 두 개를 동시에 사용할 수 없음.

             캡처 장치의 활성 형식을 설정하면 연결된 세션이 사전 설정을 AVCaptureSessionPresetInputPriority로 변경하고,
             마찬가지로 AVCaptureSession의 sessionPreset 속성을 설정하면 세션이 입력 장치의 제어를 가정하고 해당 activeFormat을 적절하게 구성함.

             오디오 장치의 경우, iOS는 사용자가 구성할 수 있는 형식(user-configurable formats)을 제공하지 않음.
             iOS에서 오디오 입력을 구성하려면 AVAudioSession API를 사용해야 함. --> 참고: AVAudioSession.h

             activeFormat, activeVideoMinFrameDuration 및 activeVideoMaxFrameDuration 속성은 AVCaptureSession의 begin/commitConfiguration 메서드를 사용하여 동시에 설정할 수 있음.

             [session beginConfiguration];  // 수신자의 AVCaptureDeviceInput이 추가되는 세션
             if ( [device lockForConfiguration:&error] ) {
                 [device setActiveFormat:newFormat];
                 [device setActiveVideoMinFrameDuration:newMinDuration];
                 [device setActiveVideoMaxFrameDuration:newMaxDuration];
                 [device unlockForConfiguration];
             }
             [session commitConfiguration];  // commitConfiguration에서 새로운 형식(format)과 프레임 레이트(frame rates)가 함께 적용됨.

             고해상도 스틸 사진을 위한 액티브 포맷(active format)을 사용하도록 세션을 구성하고 나서 AVCaptureVideoDataOutput에 다음 중 하나 이상의 작업 형태를 적용하면 목표로 한 프레임 속도를 시스템이 충족시키지 못할 수 있음.
                - 확대/축소
                - 방향 변경
                - 형식 변환
             */

            // MARK: formatDescription
            /**
             @property formatDescription
             formatDescription 프로퍼티는 AVCaptureDevice의 활성(active) 또는 지원(supported) 형식을 설명하는 CMFormatDescription임.
             이 프로퍼티는 read-only임.
             호출자는 반환된 값에 대한 소유권이 없다고 가정하며, Core Foundation object(CFRelease)로 릴리즈하면 안 됨.. 근데 이건 또 뭔지 모르겠다 ㅋㅋ

             참고: CFRelease -->. https://developer.apple.com/documentation/corefoundation/1521153-cfrelease
             */

            // MARK: unlockForConfiguration
            /**
             @method unlockForConfiguration
             장치 하드웨어 속성에 대한 독점적(exclusive) 제어를 해제함.

             unlockForConfiguration 메서드는  lockForConfiguration 메서드의 호출에 맞게(match) 호출되어야 함.
             애플리케이션이 더 이상 장치 하드웨어 속성이 자동으로 변경되는 것을 유지할 필요가 없을 때 호출하면 된다.
             */
            let dimensions = CMVideoFormatDescriptionGetDimensions((availableDevices?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            availableDevices!.unlockForConfiguration()
        } catch {
            print(error)
        }
        captureSession.commitConfiguration()

        // MARK: Preview Layer
        /// 카메라가 프레임을 애플리케이션의 UI에 제공할 수 있도록 기본 뷰 컨트롤러에서 미리보기 레이어를 설정함.

        // MARK: AVCaptureVideoPreviewLayer
        /**
         @class AVCaptureVideoPreviewLayer
         CoreAnimation 레이어의 하위 클래스. AVCaptureSession의 시각적 출력을 미리 보기 위한 것.

         AVCaptureVideoPreviewLayer 인스턴스는 CALayer의 하위 클래스임.
         따라서  그래픽 인터페이스의 일부로, 레이어 계층 구조에 삽입하는 데 적합함.

         layerWithSession 또는 initWithSession을 사용하여 미리보기를 하려는 캡처 세션이 있는 AVCaptureVideoPreviewLayer 인스턴스를 만듦.
         videoGravity 속성을 사용하면 레이어 경계를 기준으로 콘텐츠를 보는 방식에 영향을 줄 수 있음.
         일부 하드웨어의 경우 레이어의 방향은 @"orientation" 및 @"mirrored"를 사용하여 조작할 수 있음.

         ** 중요: input, output이 설정된 AVCaptureSession의 객체를 받아서 미리보기 화면의 정보를 갖는 Layer 데이터형으로, Layer이므로 따로 UIView를 만들어서 이곳에 부착하는 형태로 사용함 **


         사용례)
         private func setupLivePreview() {
             // previewLayer 세팅
             videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
             videoPreviewLayer.videoGravity = .resizeAspectFill
             videoPreviewLayer.connection?.videoOrientation = .portrait

             // UIView객체인 preView 위에 객체를 입힘
             preView.layer.insertSublayer(videoPreviewLayer, at: 0)  // 맨 앞(0번째)으로 가져와서 보이게끔 설정
             DispatchQueue.main.async { in
                 self.videoPreviewLayer.frame = self.preView.bounds
             }
             // preview까지 준비되었으니 captureSession을 시작하도록 설정
         }

         // captureSession에 시작을 알림
         private func startCaptureSession() {
             DispatchQueue.global(qos: .userInitiated).async {
                 self.captureSession.startRunning()
             }
         }
         */
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        // MARK: videoGravity
        /**
         @property videoGravity
         videoGravity 프로퍼티는 AVCaptureVideoPreviewLayer 내에서 비디오가 표시되는 방식을 정의하는 문자열임.

         옵션:
            - AVLayerVideoGravityResize
            - AVLayerVideoGravityResizeAspect. --> 기본값
            - AVLayerVideoGravityResizeAspectFill

            * 참고: 각 옵션의 설명은 AVFoundation/AVAnimation.h 참고
         */

        // MARK: resizeAspectFill
        /**
         @constant        AVLayerVideoGravityResizeAspectFill
         @abstract        Preserve aspect ratio; fill layer bounds.
         @discussion     AVLayerVideoGravityResizeAspectFill may be used when setting the videoGravity property of an AVPlayerLayer or AVCaptureVideoPreviewLayer instance.
         */
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // MARK: AIModelInferenceDisplayLayer --> root layer
        AIModelInferenceDisplayLayer = previewView.layer
        previewLayer.frame = AIModelInferenceDisplayLayer.bounds

        // MARK: addSublayer
        /**
         수신자의 하위 레이어(sublayers) 배열 마지막에 레이어를 추가함.
         하위 레이어(sublayers) 속성 내에 위치한 배열이 nil일 때, 즉 하위 레이어 속성 내부에 배열이 없을 때 이 메서드를 호출하면 해당 속성에 대한 배열이 생성되고 여기에 지정된 레이어가 추가된다.
         '레이어'에 이미 상위 레이어(superlayer)가 있는 경우 레이어 추가 전에 그 상위 레이어가 제거된다.
         */
        AIModelInferenceDisplayLayer.addSublayer(previewLayer)
    }

    func startCaptureSession() {
        captureSession.startRunning()
    }

    /// Clean up capture setup
    func teardownAVCapture() {
        // MARK: removeFromSuperlayer
        /**
         수신자가 상위 레이어(superlayer)의 하위 레이어(sublayer) 배열에 있는 경우나 상위 레이어의 마스크 값(mask value)으로 설정된 경우 모두 작동함.
         */
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }

    func captureOutput(_ captureOutput: AVCaptureOutput,
                       didDrop didDropSampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // print("frame dropped")
    }

    // MARK: Device orientation
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch curDeviceOrientation {

        // Vertical orientation -> home button on the top
        case UIDeviceOrientation.portraitUpsideDown:
            exifOrientation = .left

        // Vertical orientation -> home button on the bottom
        case UIDeviceOrientation.portrait:
            exifOrientation = .up

        // Hrizontal orientation -> home button on the left
        case UIDeviceOrientation.landscapeRight:
            exifOrientation = .down

        // Horizontal orientation -> home button on the right
        case UIDeviceOrientation.landscapeLeft:
            exifOrientation = .upMirrored

        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
