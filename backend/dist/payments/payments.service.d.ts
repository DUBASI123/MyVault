import { CreateOrderDto, PaymentGateway } from './dto/create-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
export declare class PaymentsService {
    private readonly logger;
    createOrder(dto: CreateOrderDto, studentId: string): Promise<{
        gateway: string;
        orderId: any;
        amount: any;
        currency: any;
        key: string;
        message?: undefined;
    } | {
        gateway: PaymentGateway;
        orderId: string;
        amount: number;
        currency: string;
        message: string;
        key?: undefined;
    }>;
    verifyPayment(dto: VerifyPaymentDto): Promise<{
        status: string;
        message: string;
        orderId: string;
        paymentId: string;
    }>;
}
